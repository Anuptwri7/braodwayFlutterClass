import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:rangerwholesale/model/addressModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/stringConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressProviderGet with ChangeNotifier {
  AddressModel? _addressListing;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedAddressId;

  AddressModel? get addressListing => _addressListing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedAddressId => _selectedAddressId;

  void setSelectedAddress(String? id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  Future<void> fetchAddress(context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String url =
          '${StringConst.protocol}${StringConst.baseUrl}${StringConst.address}';

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        _addressListing = AddressModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        // GlobalAuthHandler.handleUnauthorized(context);
        _errorMessage = 'Unauthorized access';
      } else {
        _errorMessage = 'Failed to fetch Address: ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = "Error fetching product data: $e";
      _addressListing = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress({
    required int? id,
    context,
    required String fullName,
    required String mobileNumber,
    required String street,
    required String city,
    required String pincode,
    required String state,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String url =
          '${StringConst.protocol}${StringConst.baseUrl}${StringConst.patchAddress}$id/';  // Assuming the API expects the ID in the URL

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.get("access_token")}',
        },
        body: jsonEncode({
          'name': fullName,
          'mobile': mobileNumber,
          'street': street,
          'city': city,
          'pincode': pincode,
          'state': state,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Address updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        await fetchAddress(context);
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(
          msg: "Failed to update address",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        // GlobalAuthHandler.handleUnauthorized(context);
        _errorMessage = 'Unauthorized access';
      } else {
        _errorMessage = 'Failed to update address: ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = "Error updating address: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
