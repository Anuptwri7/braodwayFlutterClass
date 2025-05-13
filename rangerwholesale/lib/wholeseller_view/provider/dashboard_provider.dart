import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:rangerwholesale/const/stringConst.dart';

class DashboardDataProvider extends ChangeNotifier {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardData(BuildContext context) async {
    if (_isLoading) return; // Prevent multiple concurrent fetches

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String url = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.dashboard}';

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
        _dashboardData = json.decode(response.body);
      } else {
        throw Exception('Failed to fetch dashboard data. HTTP ${response.statusCode}');
      }
    } catch (error) {
      _errorMessage = 'An error occurred while fetching data: $error';
      log('Error in DashboardProvider: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}