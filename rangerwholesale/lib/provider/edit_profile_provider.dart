import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/stringConst.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangerwholesale/provider/retailer_profile_provider.dart';

class EditRetailerProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> editRetailer({
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
    String? province,
    File? profileImage,
    required File driverLicenseImage,
    required File tobaccoPermitImage,
    required File salesTaxIdImage,
    required BuildContext context,  // Add context parameter
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.updateRetailer}'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['name'] = retailerName;
      request.fields['primaryNumber'] = primaryNumber;
      if (secondaryNumber != null && secondaryNumber.isNotEmpty) {
        request.fields['secondaryNumber'] = secondaryNumber;
      }

      // Add address fields - handle optional fields
      if (addressName != null && addressName.isNotEmpty) {
        request.fields['address[name]'] = addressName;
      }

      if (addressMobile != null && addressMobile.isNotEmpty) {
        request.fields['address[mobile]'] = addressMobile;
      }

      if (streetAddress != null && streetAddress.isNotEmpty) {
        request.fields['address[street]'] = streetAddress;
      }
      request.fields['address[city]'] = city;
      request.fields['address[pincode]'] = pincode;
      request.fields['address[state]'] = state;
      if (province != null && province.isNotEmpty) {
        request.fields['address[province]'] = province;
      }

      // Add file uploads
      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'userProfile[image]',
          profileImage.path,
        ));
      }
      request.files.add(await http.MultipartFile.fromPath(
        'userProfile[driverLicense]',
        driverLicenseImage.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'userProfile[tobaccoPermit]',
        tobaccoPermitImage.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'userProfile[salesTaxId]',
        salesTaxIdImage.path,
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var decodedResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        // Refresh the profile data immediately after successful update
        final profileProvider = Provider.of<RetailerProfileProvider>(context, listen: false);
        await profileProvider.fetchProfileData(context);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = decodedResponse['message'] ?? 'Update failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}