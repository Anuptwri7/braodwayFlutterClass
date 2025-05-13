import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/otp_page.dart';
import '../const/stringConst.dart';
import '../homePage.dart';
import '../wholeseller_view/wholeseller_home_page.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;
  String? rememberedEmail;

  LoginProvider() {
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    rememberedEmail = prefs.getString('remembered_email');
    notifyListeners();
  }

  Future<void> setRememberMe(String email, String password, bool isRemembered) async {
    final prefs = await SharedPreferences.getInstance();
    if (isRemembered) {
      await prefs.setString('remembered_email', email);
      rememberedEmail = email;
    } else {
      await prefs.remove('remembered_email');
      rememberedEmail = null;
    }
    notifyListeners();
  }

  /// Handles user login
  Future<void> login(String email, String password, bool isRememberMe, BuildContext context) async {
    List<String> getCodeName = [];
    isLoading = true;
    notifyListeners();

    try {
      await setRememberMe(email, password, isRememberMe);
      final url = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.login}';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
        final responseBody = json.decode(response.body);
        await _saveTokens(
          accessToken: responseBody['access'] ?? '',
          refreshToken: responseBody['refresh'] ?? '',
        );

        // Store user data in SharedPreferences
        sharedPreferences.setString(
            "photo", responseBody['userImage'] ?? '#');
        sharedPreferences.setString(
            "user_name", responseBody['userFullname'] ?? '#');
        sharedPreferences.setString(
            "email", responseBody['userEmail'] ?? '#');
        // Store isSuperuser status
        sharedPreferences.setBool(
            "is_superuser", responseBody['isSuperuser'] ?? false);
        sharedPreferences.setBool("is_verified_by_admin", responseBody['isVerifiedByAdmin'] ?? false);

        for (var permission in responseBody['userPermissions']) {
          var codeName = permission;
          if (!getCodeName.contains(codeName)) {
            getCodeName.add(codeName);
          }
        }
        sharedPreferences.setStringList("permission", getCodeName);

        log("Login successful: ${responseBody['userType']}");

        Fluttertoast.showToast(
          msg: "Login successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        final String userType = responseBody['userType'] ?? '';
        sharedPreferences.setString("userType", userType);
        if (userType == "whole_seller") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WholeSellerHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepage()),
          );
        }
      } else {
        await _handleLoginError(response, email, context);
      }
    } catch (error) {
      log("Login Error: $error");
      Fluttertoast.showToast(
        msg: "Internal Server Error. Please Contact IT manager !!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out the user by clearing tokens
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await TokenManager.instance.clearTokens();
    notifyListeners();
    String? rememberedEmail = prefs.getString('remembered_email');
    await prefs.clear();
    if (rememberedEmail != null) {
      await prefs.setString('remembered_email', rememberedEmail);
    }

    Fluttertoast.showToast(
      msg: "Logout successful",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    notifyListeners();
  }

  /// Sends OTP to the user's email
  Future<void> _sendOtp(String email) async {
    try {
      final url = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.otpRequest}';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "OTP sent successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown error';
        Fluttertoast.showToast(
          msg: "Error: $errorMessage",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      log("OTP Error: $error");
      Fluttertoast.showToast(
        msg: "Error: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  /// Saves the access and refresh tokens to shared preferences
  Future<void> _saveTokens({required String accessToken, required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", accessToken);
    await prefs.setString("refresh_token", refreshToken);
  }

  /// Handles login errors, including inactive accounts
  Future<void> _handleLoginError(http.Response response, String email, BuildContext context) async {
    final responseBody = jsonDecode(response.body);
    final String errorMessage = responseBody['message'] ?? 'Invalid credentials';
    final bool isActive = responseBody['data']?['isActive'] ?? true;
    final bool deactivate = responseBody['data']?['deactivated'] ?? true;

    log("Login failed: $errorMessage");

    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );

    if (!isActive && !deactivate) {
      await _sendOtp(email);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpPage(email: email)),
      );
    }
  }
}