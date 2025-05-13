import 'package:flutter/material.dart';
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../const/stringConst.dart';
import '../model/category_lisiting_model.dart';

class CategoryListingProvider with ChangeNotifier {
  List<Data> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  Pagination? _pagination;
  int _currentPage = 1;
  final int _pageSize = 10;
  String _searchQuery = '';

  // Getters
  List<Data> get categories => _categories;

  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  String? get errorMessage => _errorMessage;

  Pagination? get pagination => _pagination;

  void resetState() {
    _searchQuery = '';
    _categories = [];
    _currentPage = 1;
    _pagination = null;
    _errorMessage = null;
  }

  Future<void> fetchCategories(context,
      {bool loadMore = false, String? searchQuery}) async {
    // Handle search query
    if (!loadMore && searchQuery != null) {
      _searchQuery = searchQuery;
      _categories.clear();
      _currentPage = 1;
      loadMore = false;
    }

    // Handle pagination
    if (loadMore) {
      if (_pagination?.next == null) return;
      _isLoadingMore = true;
      _currentPage++;
    } else {
      if (_isLoading) return;
      _isLoading = true;
      if (searchQuery == null && !loadMore) {
        _currentPage = 1;
        _categories.clear();
      }
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      if (token == null) {
        throw Exception('No access token found');
      }

      final queryParams = {
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      };

      final uri = Uri.parse(
              '${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchCategory}')
          .replace(queryParameters: queryParams);

      final response = await TokenManager.instance.authenticatedRequest(
        (token) => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        context,
      );

      if (response.statusCode == 401) {
        // GlobalAuthHandler.handleUnauthorized(context);
        _errorMessage = 'Unauthorized';
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final categoryListing = CategoryListing.fromJson(jsonResponse);

        if (loadMore) {
          _categories.addAll(categoryListing.data ?? []);
        } else {
          _categories = categoryListing.data ?? [];
        }
        _pagination = categoryListing.pagination;
      } else {
        _errorMessage = 'Failed to fetch categories: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clearSearch(context) {
    _searchQuery = '';
    _categories.clear();
    _currentPage = 1;
    _pagination = null;
    fetchCategories(context);
  }
}
