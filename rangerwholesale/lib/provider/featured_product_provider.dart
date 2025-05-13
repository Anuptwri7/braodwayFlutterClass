import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../const/stringConst.dart';

class FeaturedProductProvider with ChangeNotifier {
  List<dynamic> featuredProducts = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  bool hasNextPage = true;
  int currentPage = 1;
  final int limit = 10;

  Future<void> fetchFeaturedProducts({
    String? searchQuery,
    int page = 1,
    bool isInitialLoad = true,
    required BuildContext context
  }) async {
    if (isInitialLoad ? isLoading : isLoadingMore) return;

    if (isInitialLoad) {
      isLoading = true;
      errorMessage = null;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Base URL construction
      String url = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchProductScan}?limit=$limit&offset=$page';

      // Add category ID only if there's no search query
      if (searchQuery == null || searchQuery.isEmpty) {
        url += '&category_shopify_id=293686378666';
      } else {
        url += '&search=$searchQuery';
      }

      log('Fetching featured products from URL: $url');
      log("is_verified_by_admin: ${prefs.getBool("is_verified_by_admin")}");

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

      if (response.statusCode == 401) {
        errorMessage = 'Unauthorized access';
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        log('Raw response data: $jsonData');

        List<dynamic> newFeaturedProducts = jsonData['data'] ?? [];

        if (page == 1) {
          featuredProducts = newFeaturedProducts;
        } else {
          featuredProducts.addAll(newFeaturedProducts);
        }

        hasNextPage = newFeaturedProducts.length == limit;
        currentPage = page;
      } else {
        errorMessage = 'Failed to fetch featured products: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'An error occurred: ${e.toString()}';
    } finally {
      if (isInitialLoad) {
        isLoading = false;
      } else {
        isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  Future<void> loadMoreFeaturedProducts({String? searchQuery,required BuildContext context}) async {
    if (hasNextPage && !isLoadingMore) {
      await fetchFeaturedProducts(
        page: currentPage + 1,
        isInitialLoad: false,
        searchQuery: searchQuery,
        context: context,
      );
    }
  }

  dynamic getProductAt(int index) {
    if (index >= 0 && index < featuredProducts.length) {
      return featuredProducts[index];
    }
    return null;
  }
}