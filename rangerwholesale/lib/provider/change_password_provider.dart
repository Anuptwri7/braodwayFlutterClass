import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the fluttertoast package

import '../const/stringConst.dart';
import '../const/styleConst.dart';

class ChangePasswordProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // POST request to change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Initialize loading state
    _isLoading = true;
    notifyListeners();

    // Check if the new password and confirm password match
    if (newPassword != confirmPassword) {
      _errorMessage = "New password and confirm password do not match";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Retrieve the access token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");

    if (token == null) {
      _errorMessage = "Authorization token is missing.";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Make the HTTP request to change the password
    try {
      final response = await http.post(
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.changePassword}'),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      // Handle the response based on status code
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true; // Password changed successfully
      } else {
        try {
          final responseBody = jsonDecode(response.body);
          final errors = responseBody['errors'];
          if (errors.containsKey('newPassword') && errors['newPassword'].isNotEmpty) {
            _errorMessage = errors['newPassword'][0];
          } else if (errors.containsKey('currentPassword') && errors['currentPassword'].isNotEmpty) {
            _errorMessage = errors['currentPassword'][0];
          }
        } catch (e) {
          _errorMessage = 'Something went wrong.';
        }
        _isLoading = false;
        notifyListeners();

        // Optionally show an error toast
        Fluttertoast.showToast(
          msg: _errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.mainAppColor,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return false; // Error occurred in the response
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();

      // Show a toast for the exception
      Fluttertoast.showToast(
        msg: "An error occurred",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return false; // Exception occurred
    }
  }
}
