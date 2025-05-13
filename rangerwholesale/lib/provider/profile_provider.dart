import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/stringConst.dart';
import '../model/profile_model.dart';

class ProfileProvider with ChangeNotifier {
  ProfileModel? _profileModel;
  bool _isLoading = false;
  String _errorMessage = '';

  ProfileModel? get profileModel => _profileModel;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  void clearProfileData() {
    _profileModel = null;
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> fetchProfileData(context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString("access_token");

      if (accessToken == null || accessToken.isEmpty) {
        _errorMessage = 'No access token found. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse(
        '${StringConst.protocol}${StringConst.baseUrl}${StringConst.userDetail}',
      );

      final response = await TokenManager.instance.authenticatedRequest(
        (token) => http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        context,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _profileModel = ProfileModel.fromJson(jsonResponse);
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load profile data. Please try again later.';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Method to update the profile data with PATCH request
  Future<void> updateProfileData(BuildContext context, String fullName,
      String email, String mobileNumber, File? image) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString("access_token");

      if (accessToken == null || accessToken.isEmpty) {
        _errorMessage = 'No access token found. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse(
        '${StringConst.protocol}${StringConst.baseUrl}${StringConst.userDetail}',
      );

      var request = http.MultipartRequest('PATCH', url)
        ..headers.addAll({
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });

      // Prepare the data to be updated
      request.fields['fullName'] = fullName;
      request.fields['email'] = email;
      request.fields['phone'] = mobileNumber;

      if (image != null) {
        // If image is provided, include it in the multipart request
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }
      log(image.toString());
      final response = await request.send();

      if (response.statusCode == 200) {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        sharedPreferences.setString(
            "photo", jsonResponse['data']['userProfile']['image'] ?? '#');
        sharedPreferences.setString("user_name",
            jsonResponse['data']['userProfile']['fullName'] ?? '#');
        sharedPreferences.setString(
            "email", jsonResponse['data']['email'] ?? '#');
        Navigator.of(context).pop();
        _profileModel =
            ProfileModel.fromJson(jsonResponse); // Update the profile model
        _errorMessage = '';
        // Show a success toast
        Fluttertoast.showToast(
          msg: "Profile updated successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        _errorMessage = 'Failed to update profile. Please try again later.';
        Fluttertoast.showToast(
          msg: "Failed to update profile. Please try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.mainAppColor,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    }

    _isLoading = false;
    notifyListeners();
  }
}
