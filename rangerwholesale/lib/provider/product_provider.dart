import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../const/stringConst.dart';

class ProductProvider with ChangeNotifier {
  List<dynamic> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNextPage = true;
  int _currentPage = 1;
  final int _limit = 10;

  List<dynamic> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;


  void clearProducts() {
    _products = [];
    _currentPage = 1;
    _hasNextPage = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProducts(
      int? categoryId, {
        bool? isFeatured,
        String? searchQuery,
        int page = 1,
        int limit = 40,
        required BuildContext context
      }) async {
    if (_isLoading) return;

    if (page == 1) {
      clearProducts();
    }

    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String url = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchProductScan}?limit=$limit&offset=$page';

      if (categoryId != null) {
        url += '&category=$categoryId';
      }
      if (isFeatured != null) {
        url += '&is_featured=$isFeatured';
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url += '&search=$searchQuery';
      }

      log('Fetching products from URL: $url');

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
        _errorMessage = 'Unauthorized access';
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> newProducts = jsonData['data'] ?? jsonData['products'] ?? [];

        if (page == 1) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        _hasNextPage = newProducts.length == limit;
        _currentPage = page;
      } else {
        _errorMessage = 'Failed to fetch products: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      log('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore(context) async {
    if (_hasNextPage && !_isLoading) {
      await fetchProducts(
        null,
        page: _currentPage + 1,
        limit: _limit,
        context: context,
      );
    }
  }
}