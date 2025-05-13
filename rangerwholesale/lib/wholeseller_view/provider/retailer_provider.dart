import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:rangerwholesale/const/stringConst.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RetailerProvider extends ChangeNotifier {
  List<dynamic> retailers = [];
  bool isLoading = false;
  String? error;
  int currentPage = 1;
  int limit = 10;
  bool hasMoreData = true;
  String searchQuery = '';
  Timer? _debounceTimer;

  void resetState() {
    retailers.clear();
    currentPage = 1;
    hasMoreData = true;
    searchQuery = "";
    notifyListeners();
  }

  Future<void> searchRetailers(String query,context) async {
    _debounceTimer?.cancel();
    searchQuery = query;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchRetailers(refresh: true,context: context);
    });
  }

  Future<void> fetchRetailers({bool refresh = false,required BuildContext context}) async {
    if (refresh) {
      currentPage = 1;
      retailers = [];
      hasMoreData = true;
    }

    if (!hasMoreData || isLoading) return;

    isLoading = true;
    if (currentPage == 1) error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("access_token");

      if (accessToken == null) {
        error = 'Authentication token not found';
        isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse(
          '${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchRetailers}?offset=$currentPage&limit=$limit&search=$searchQuery');

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
        final responseBody = json.decode(response.body);

        if (responseBody['success'] == true && responseBody['data'] is List) {
          final newRetailers = responseBody['data'];
          if (refresh) {
            retailers = newRetailers;
          } else {
            retailers.addAll(newRetailers);
          }

          hasMoreData = newRetailers.length >= limit;
          if (hasMoreData) currentPage++;

          log('Retailers fetched: ${retailers.length} retailers');
        } else {
          if (currentPage == 1) {
            error = responseBody['message'] ?? 'Failed to retrieve retailers';
            retailers = [];
          }
        }
      } else {
        if (currentPage == 1) {
          error =
              'Failed to load retailers. Status code: ${response.statusCode}';
          retailers = [];
        }
        log('Error response: ${response.body}');
      }
    } catch (e) {
      if (currentPage == 1) {
        error = 'Network error: ${e.toString()}';
        retailers = [];
      }
      log('Fetch retailers error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyRetailer(int retailerId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("access_token");

      if (accessToken == null) {
        error = 'Authentication token not found';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final url = Uri.parse(
          '${StringConst.protocol}${StringConst.baseUrl}${StringConst.patchRetailers}$retailerId/');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'is_verified_by_admin': true}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['success'] == true) {
          _updateLocalRetailerVerificationStatus(retailerId);

          log('Retailer verified successfully');
          return true;
        } else {
          error = responseBody['message'] ?? 'Failed to verify retailer';
          return false;
        }
      } else {
        error =
            'Failed to verify retailer. Status code: ${response.statusCode}';

        log('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      error = 'Network error: ${e.toString()}';
      log('Verify retailer error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateAccount(int retailerId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("access_token");

      if (accessToken == null) {
        error = 'Authentication token not found';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final url = Uri.parse(
          '${StringConst.protocol}${StringConst.baseUrl}${StringConst.deactivateAccount}$retailerId');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['success'] == true) {
          retailers.removeWhere((retailer) => retailer['id'] == retailerId);
          notifyListeners();
          log('Retailer deleted successfully');
          return true;
        } else {
          error = responseBody['error']?['errors'] ?? responseBody['message'];
          return false;
        }
      } else {
        final responseBody = json.decode(response.body);
        error = responseBody['errors']?['error'][0] ??
            'Failed to delete retailer. Status code: ${response.statusCode}';
        log('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      error = 'Network error: ${e.toString()}';
      log('Delete retailer error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRetailer(int retailerId, String email) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("access_token");

      if (accessToken == null) {
        error = 'Authentication token not found';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final url = Uri.parse(
          '${StringConst.protocol}${StringConst.baseUrl}${StringConst.deleteRetailer}');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['success'] == true) {
          // Remove the deleted retailer from the local list
          retailers.removeWhere((retailer) => retailer['id'] == retailerId);
          notifyListeners();
          log('Retailer deleted successfully');
          return true;
        } else {
          error = responseBody['error']?['errors'] ?? responseBody['message'];
          return false;
        }
      } else {
        final responseBody = json.decode(response.body);
        error = responseBody['errors']?['error'][0] ??
            'Failed to delete retailer. Status code: ${response.statusCode}';
        log('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      error = 'Network error: ${e.toString()}';
      log('Delete retailer error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _updateLocalRetailerVerificationStatus(int retailerId) {
    for (var i = 0; i < retailers.length; i++) {
      if (retailers[i]['users'][0]['id'] == retailerId) {
        if (retailers[i]['users'] != null && retailers[i]['users'].isNotEmpty) {
          retailers[i]['users'][0]['isVerifiedByAdmin'] = true;
        }
        break;
      }
    }
    notifyListeners();
  }
}
