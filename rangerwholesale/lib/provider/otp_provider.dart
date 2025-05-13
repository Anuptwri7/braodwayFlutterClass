import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/stringConst.dart';

class OtpProvider extends ChangeNotifier {
  bool isLoading = false;

  // Change Password Method
  Future<void> changePassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    if (newPassword != confirmPassword) {
      Fluttertoast.showToast(
        msg: "New password and confirm password do not match",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.otpChangePassword}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Password changed successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      } else {
        final errorMessage = jsonDecode(response.body)['errors']['newPassword'][0] ?? 'Unknown error';
        log("Change password failed: $errorMessage");

        Fluttertoast.showToast(
          msg: "$errorMessage",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      log("Error: $error");
      Fluttertoast.showToast(
        msg: "Error: $error",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Forget Password Method
  Future<bool> forgetPassword({
    required String email,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.forgetPassword}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "OTP sent to your email",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        return true;
      } else {
        try {
          final errorMessage = jsonDecode(response.body)['errors']['email'][0] ?? 'Unknown error';
          log("Forget password failed: $errorMessage");

          Fluttertoast.showToast(
            msg: "$errorMessage",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        } catch (e, stackTrace) {
          final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown error';
          log("An unexpected error occurred: $e", error: e, stackTrace: stackTrace);

          Fluttertoast.showToast(
            msg: "$errorMessage",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } catch (error) {
      log("Error: $error");
      Fluttertoast.showToast(
        msg: "Error: $error",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
