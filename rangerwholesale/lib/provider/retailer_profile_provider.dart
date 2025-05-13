import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/const/stringConst.dart';
import '../auth/auth_handler.dart';

class RetailerProfileProvider with ChangeNotifier {
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfileData(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final String url = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.userDetail}';

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
        _profileData = json.decode(response.body);
      } else {
        throw Exception('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfileData() {
    _profileData = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Getter methods for easy access to profile data
  int get id => _profileData?['data']?['id'];
  String get fullName => _profileData?['data']?['userProfile']?['fullName'] ?? 'Username';
  String get email => _profileData?['data']?['email'] ?? 'email@example.com';
  String get phone => _profileData?['data']?['userProfile']?['phone'] ?? '**********';
  String? get profileImage => _profileData?['data']?['userProfile']?['image'];
}