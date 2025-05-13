import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../const/stringConst.dart';
import '../model/subCategory_listing_model.dart';

class SubcategoryProvider with ChangeNotifier {
  List<SubcategoryData>? _subcategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SubcategoryData>? get subcategories => _subcategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSubcategories(int? categoryId) async {
    if (_isLoading || categoryId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(
        Uri.parse(
          '${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchSubcategory}$categoryId/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("access_token")}',
        },
      );

      // Handle response
      if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized access';
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse and store the subcategories from the response
        final jsonData = jsonDecode(response.body);
        _subcategories = SubCategoryListing.fromJson(jsonData).data ?? [];
      } else {
        _errorMessage = 'Failed to fetch subcategories';
      }
    } catch (e) {
      // Handle any errors
      _errorMessage = 'An error occurred: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
