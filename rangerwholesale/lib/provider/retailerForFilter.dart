import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:rangerwholesale/const/stringConst.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RetailerForFilterProvider with ChangeNotifier {
  List<dynamic> retailers = [];
  bool isLoading = false;
  String? errorMessage;
  int currentPage = 1;
  bool hasMoreData = true;
  final int limit = 50; // Increased limit to fetch more data at once
  bool isLoadingMore = false;
  bool isDropdownOpen = false;

  Future<void> fetchRetailers({
    bool refresh = false,
    required BuildContext context,
  }) async {
    if (refresh) {
      retailers = [];
      currentPage = 1;
      hasMoreData = true;
    }

    if (!hasMoreData || isLoading) return;

    if (refresh) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("access_token");
      if (accessToken == null) {
        throw Exception('Authentication token not found');
      }

      final url = Uri.parse(
        '${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchRetailerForFilter}?page=$currentPage&limit=$limit',
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
        final data = json.decode(response.body);
        final List<dynamic> newRetailers = data['data'] ?? [];

        if (refresh) {
          retailers = newRetailers;
        } else {
          retailers.addAll(newRetailers);
        }

        hasMoreData = newRetailers.length >= limit;
        if (hasMoreData) {
          currentPage++;
        }
        errorMessage = null;
      } else {
        errorMessage = 'Failed to load retailers';
        log('Failed to load retailers: ${response.statusCode}');
      }
    } catch (error) {
      errorMessage = 'Error: $error';
      log('Error fetching retailers: $error');
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadAllRetailers(BuildContext context) async {
    while (hasMoreData && !isLoading) {
      await fetchRetailers(context: context);
    }
  }

  void setDropdownState(bool isOpen) {
    isDropdownOpen = isOpen;
    notifyListeners();
  }

  void resetState() {
    retailers = [];
    currentPage = 1;
    hasMoreData = true;
    errorMessage = null;
    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }
}