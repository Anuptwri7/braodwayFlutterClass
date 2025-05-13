import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rangerwholesale/const/stringConst.dart';

class SignUpProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  bool _registrationSuccessful = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get registrationSuccessful => _registrationSuccessful;

  Future<bool> submitRetailerRegistration({
    required String retailerName,
    required String email,
    required String primaryNumber,
    String? secondaryNumber,
    String? addressName,
    String? addressMobile,
    String? streetAddress,
    required String city,
    required String pincode,
    required String state,
    File? profileImage,
    File? driverLicenseImage,
    File? tobaccoPermitImage,
    File? salesTaxIdImage,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _registrationSuccessful = false;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.signup}')
      );

      request.fields.addAll({
        'retailer_name': retailerName,
        'email': email,
        'primary_number': primaryNumber,
        'secondary_number': secondaryNumber ?? '',
        'address_name': addressName ?? '',
        'address_mobile': addressMobile ?? '',
        'address_street': streetAddress ?? '',
        'address_city': city,
        'address_pincode': pincode,
        'address_state': state,
      });

      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath('image', profileImage.path));
      }
      if (driverLicenseImage != null) {
        request.files.add(await http.MultipartFile.fromPath('driver_license', driverLicenseImage.path));
      }
      if (tobaccoPermitImage != null) {
        request.files.add(await http.MultipartFile.fromPath('tobacco_permit', tobaccoPermitImage.path));
      }
      if (salesTaxIdImage != null) {
        request.files.add(await http.MultipartFile.fromPath('sales_tax_id', salesTaxIdImage.path));
      }


      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log(response.body);
      switch (response.statusCode) {
        case 200: // OK
        case 201: // Created
          _registrationSuccessful = true;
          _isLoading = false;
          notifyListeners();
          return true;
        case 400: // Bad Request
          final responseBody = json.decode(response.body);
          _errorMessage = responseBody['errors']['error'][0] ?? 'Invalid registration data.';
          break;
        case 401: // Unauthorized
          _errorMessage = 'Authentication failed. Please check your credentials.';
          break;
        case 403: // Forbidden
          _errorMessage = 'You do not have permission to register.';
          break;
        case 409: // Conflict
          _errorMessage = 'An account with this email already exists.';
          break;
        case 500: // Internal Server Error
          _errorMessage = 'Server error. Please try again later.';
          break;
        default:
          _errorMessage = 'Unexpected error occurred. Status code: ${response.statusCode}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on SocketException {
      _errorMessage = 'No internet connection. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FormatException {
      _errorMessage = 'Error processing server response.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = '';
    _registrationSuccessful = false;
    notifyListeners();
  }
}