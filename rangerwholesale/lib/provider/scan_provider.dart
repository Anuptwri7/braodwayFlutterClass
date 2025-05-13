import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_handler.dart';
import '../const/stringConst.dart';

class ScanProvider with ChangeNotifier {
  Map<String, dynamic>? _scanData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get scanData => _scanData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearScanData() {
    _scanData = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> fetchScanData(String barcode, BuildContext context) async {
    try {
      _isLoading = true;
      clearScanData();
      notifyListeners();

      final String url = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.scanItem}?bar_code=$barcode';

      final response = await TokenManager.instance.authenticatedRequest(
            (token) => http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        context,
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        // Check if the response contains valid product data
        if (decodedData != null &&
            decodedData['data'] != null &&
            decodedData['data']['productVariants'] != null &&
            (decodedData['data']['productVariants'] as List).isNotEmpty) {
          _scanData = decodedData;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // _handleError("No products found");
          return false;
        }
      } else {
        _handleError("Failed to fetch data");
        return false;
      }
    } catch (e) {
      // _handleError("Products not found");
      return false;
    }
  }

  void _handleError(String message) {
    _isLoading = false;
    _errorMessage = message;
    _scanData = null;
    notifyListeners();

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}