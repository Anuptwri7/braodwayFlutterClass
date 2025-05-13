import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:rangerwholesale/const/stringConst.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/provider/cart_provider.dart';
import 'package:rangerwholesale/tabPages/my_orders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  static const int _pageSize = 10;
  String? _lastSearchQuery;
  String? _lastCategory;
  List<Map<String, dynamic>> get orders => _orders;

  bool get isLoading => _isLoading;

  bool get hasMoreData => _hasMoreData;

  Future<void> getOrders(
      BuildContext context,
      String? searchQuery,
      String? selectedCategory, {
        bool refresh = false,
      }) async {
    // If refreshing or search/category changed, reset pagination
    if (refresh || searchQuery != _lastSearchQuery || selectedCategory != _lastCategory) {
      _currentPage = 1;
      _orders = [];
      _hasMoreData = true;
      _lastSearchQuery = searchQuery;
      _lastCategory = selectedCategory;
    }

    // Don't fetch if we're already loading or if we know there's no more data
    if (_isLoading || (!_hasMoreData && !refresh)) return;

    try {
      _isLoading = true;
      notifyListeners();

      String baseUrl = '${StringConst.protocol}${StringConst.baseUrl}${StringConst.getOrders}';
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
        if (searchQuery?.isNotEmpty ?? false) 'search': searchQuery,
        if (selectedCategory?.isNotEmpty ?? false) 'status': selectedCategory,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> newOrders = jsonResponse['data'] ?? [];

        _hasMoreData = newOrders.length >= _pageSize;

        if (newOrders.isNotEmpty) {
          _orders.addAll(List<Map<String, dynamic>>.from(newOrders));
          _currentPage++;
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      log('Error fetching orders: $e');
      _showToast("An error occurred while fetching orders", isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> placeOrder({
    required BuildContext context,
    required List<dynamic> cartItems,
    required String shippingAddressId,
    required String? selfPicked,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isLoading = true;
      notifyListeners();

      // Show loading dialog
      _showLoadingDialog(context);

      final body = {
        "cart_item_ids": cartItems,
        "shipping_address_id": int.parse(shippingAddressId),
        "mode_of_delivery": selfPicked ?? "delivery",
      };

      final response = await http.post(
        Uri.parse(
            '${StringConst.protocol}${StringConst.baseUrl}${StringConst.placeOrder}'),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("access_token")}',
        },
        body: jsonEncode(body),
      );

      // Always close the loading dialog first
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _handleOrderSuccess(context);
      }else {
        _handleOrderError(response);
      }
    } catch (e) {
      log('Error placing order: $e');
      // Make sure to close loading dialog if there's an error
      // if (context.mounted) Navigator.of(context).pop();
      _showToast("An error occurred while placing the order", isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleOrderSuccess(BuildContext context) {
    _showToast("Order Placed Successfully");
    Provider.of<CartProvider>(context, listen: false).fetchCartData(context);
    showOrderStatusDialog(context);
    log('Order placed successfully');
  }

  void _handleOrderError(http.Response response) {
    final errorResponse = jsonDecode(response.body);
    String errorMessage = 'Failed to place order';

    if (errorResponse['errors']?['nonFieldErrors'] is List &&
        (errorResponse['errors']['nonFieldErrors'] as List).isNotEmpty) {
      errorMessage = errorResponse['errors']['nonFieldErrors'][0];
    }

    // _showToast(errorMessage, isError: true);
  }

  void _handleError(http.Response response) {
    final errorResponse = jsonDecode(response.body);
    String errorMessage = 'Failed to fetch orders';

    if (errorResponse['errors']?['nonFieldErrors'] is List &&
        (errorResponse['errors']['nonFieldErrors'] as List).isNotEmpty) {
      errorMessage = errorResponse['errors']['nonFieldErrors'][0];
    }

    // _showToast(errorMessage, isError: true);
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: LoadingAnimationWidget.threeArchedCircle(
            color: AppColors.mainAppColor,
            size: 40,
          ),
        );
      },
    );
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showOrderStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainAppColor,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Order Placed Successfully',
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              'You have successfully placed the order',
              style: TextStyle(fontFamily: "poppins", fontSize: 16),
              textAlign: TextAlign.center,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyOrders()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'View Order Status',
                      style: TextStyle(
                        fontFamily: "poppins",
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
