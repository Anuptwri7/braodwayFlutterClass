import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangerwholesale/const/stringConst.dart';

class WholeSellerOrderProvider with ChangeNotifier {
  List<dynamic> orders = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  String? searchQuery;
  static const int itemsPerPage = 10;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  String? _retailerId;
  String? _status;
  String? _selectedModeOfDelivery;

  void resetFilters(context) {
    _retailerId = null;
    _status = null;
    _selectedModeOfDelivery = null;
    resetState();
    fetchWholeSellerOrders(context);
  }

  void applyFilters({
    String? retailerId,
    String? status,
    String? modeOfDelivery,
    required BuildContext context
  }) {
    _retailerId = retailerId;
    _status = status;
    _selectedModeOfDelivery = modeOfDelivery;
    resetState();
    fetchWholeSellerOrders(context);
  }

  Future<void> fetchWholeSellerOrders(context) async {
    if (isLoading || (!hasMoreData && currentPage > 1)) return;

    isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) throw Exception('Access token not found');

      final queryParams = {
        'page': currentPage.toString(),
        'limit': itemsPerPage.toString(),
        if (searchQuery?.isNotEmpty ?? false) 'search': searchQuery!,
        if (_retailerId != null) 'user': _retailerId!,
        if (_status != null) 'status': _status!,
        if (_selectedModeOfDelivery != null) 'mode_of_delivery': _selectedModeOfDelivery!,
      };

      final url = Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchOrdersAdmin}')
          .replace(queryParameters: queryParams);

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
        final jsonData = json.decode(response.body);
        final newOrders = List<dynamic>.from(jsonData['data'] ?? []);

        if (currentPage == 1) {
          orders = newOrders;
        } else {
          orders.addAll(newOrders);
        }

        hasMoreData = newOrders.length >= itemsPerPage;
      }else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Failed to fetch orders';
        throw Exception(errorMessage);
      }
    } catch (error) {
      // Fluttertoast.showToast(
      //   msg: error.toString(),
      //   backgroundColor: Colors.red,
      //   textColor: Colors.white,
      // );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void loadMoreOrders(context) {
    if (!isLoading && hasMoreData) {
      currentPage++;
      fetchWholeSellerOrders(context);
    }
  }

  void searchOrders(String query, context) {
    searchQuery = query.trim();
    orders.clear();
    currentPage = 1;
    hasMoreData = true;
    fetchWholeSellerOrders(context);
  }

  Future<void> updateOrderStatus(int orderId, String mode) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) throw Exception('Access token not found');

      final response = await http.patch(
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.fetchOrdersAdmin}$orderId/'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: {
          'status': mode == 'self-pick' ? 'self-picked' : 'delivered'
        },
      );

      if (response.statusCode == 200) {
        // Update the order status locally
        final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          orders[orderIndex]['status'] = mode == 'self-pick' ? 'self-picked' : 'delivered';
          notifyListeners();
        }

        Fluttertoast.showToast(
          msg: 'Order status updated successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void resetState() {
    orders.clear();
    currentPage = 1;
    hasMoreData = true;
    searchQuery = null;
    notifyListeners();
  }
}