import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../const/stringConst.dart';

class Address {
  final int id;
  final String name;
  final String mobile;
  final String street;
  final String city;
  final String state;
  final String? pinCode;

  Address({
    required this.id,
    required this.name,
    required this.mobile,
    required this.street,
    required this.city,
    required this.state,
    this.pinCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pinCode: json['pincode'],
    );
  }
}

class AddressProvider with ChangeNotifier {
  List<Address> _addresses = [];

  List<Address> get addresses => _addresses;

  Future<void> fetchAddresses() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.get(
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.address}'),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.get("access_token")}',
        },
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch addresses: ${response.statusCode} ${response.body}');
      }

      final List<dynamic> addressList = json.decode(response.body);
      _addresses = addressList.map((data) => Address.fromJson(data)).toList();

      notifyListeners();
    } catch (error) {
      log('Error fetching addresses: $error');
      throw error;
    }
  }

  Future<void> saveAddress({
    required String name,
    required String mobile,
    required String street,
    required String city,
    required String state,
    required String? pinCode,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.address}'),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.get("access_token")}',
        },
        body: json.encode({
          'name': name,
          'mobile': mobile,
          'street': street,
          'city': city,
          'state': state,
          'pincode': pinCode,
        }),
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to save address: ${response.statusCode} ${response.body}');
      }

      // Show success toast message
      Fluttertoast.showToast(
        msg: "Address saved successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Optionally, you can refetch addresses here or add the new address to the list
      fetchAddresses(); // Fetch updated list of addresses

      notifyListeners();
    } catch (error) {
      // Show error toast message
      Fluttertoast.showToast(
        msg: 'Error saving address: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      throw error; // Propagate the error further
    }
  }

  Future<void> deleteAddress(int addressId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.delete(
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.address}$addressId/'),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.get("access_token")}',
        },
      );

      if (response.statusCode >= 400) {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Failed to delete address';

        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        throw Exception('Failed to delete address: ${response.statusCode} $errorMessage');
      }

      // Remove the address from the local list
      _addresses.removeWhere((address) => address.id == addressId);

      // Show success toast message
      Fluttertoast.showToast(
        msg: "Address deleted successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Notify listeners to update the UI
      notifyListeners();
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error deleting address: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      throw error;
    }
  }
}
