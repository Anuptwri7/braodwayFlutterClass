import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:rangerwholesale/const/stringConst.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProductProvider with ChangeNotifier {
  List<dynamic> products = [];
  bool isLoading = false;
  String? errorMessage;

  // Pagination properties
  int totalCount = 0;
  int currentPage = 1;
  int totalPages = 0;
  int limit = 10;

  Future<void> fetchProducts({String? searchQuery, bool loadMore = false,required BuildContext context}) async {
    // If not loading more, reset the list and page
    if (!loadMore) {
      products.clear();
      currentPage = 1;
    } else {
      // Increment page for loading more
      currentPage++;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Construct URL with current page and limit
      String url = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchProductsAdmin}?limit=$limit&offset=$currentPage';

      // Add search query if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url += '&search=$searchQuery';
      }

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
        final data = json.decode(response.body);

        // Parse pagination info
        final pagination = data['pagination'] ?? {};
        totalCount = pagination['count'] ?? 0;
        totalPages = pagination['totalPages'] ?? 0;

        // Add new products to the existing list
        final newProducts = data['data'] ?? [];

        // If it's the first page, clear the list
        if (currentPage == 1) {
          products.clear();
        }

        // Add new products
        products.addAll(newProducts);

      }
      else {
        // If loading more fails, decrement the page
        if (loadMore) currentPage--;

        errorMessage = 'Failed to load products';
      }
    } catch (error) {
      // If loading more fails, decrement the page
      if (loadMore) currentPage--;

      errorMessage = 'Error fetching products: $error';
      log(errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to check if more products can be loaded
  bool get hasMoreProducts => currentPage < totalPages;

  // Method to reset pagination
  void resetPagination() {
    products.clear();
    currentPage = 1;
    totalPages = 0;
    totalCount = 0;
  }
}