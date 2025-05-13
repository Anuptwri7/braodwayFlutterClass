import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rangerwholesale/auth/auth_handler.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/stringConst.dart';

class CartProvider with ChangeNotifier {
  List<dynamic> _cartItems = [];
  bool isLoading = false;
  String? errorMessage;
  Map<int, bool> isUpdatingQuantity = {}; // Track loading state per item
  double _cartTotal = 0.0;

  List<dynamic> get cartItems => _cartItems;
  double get cartTotal => _cartTotal;

  Future<void> fetchCartData(context) async {
    // Begin loading and notify UI
    isLoading = true;
    errorMessage = null;
    _cartItems.clear(); // Clear existing data to avoid stale items
    notifyListeners();

    try {
      final response = await TokenManager.instance.authenticatedRequest(
            (token) => http.get(
          Uri.parse(
              "${StringConst.protocol + StringConst.baseUrl + StringConst.getCartItems}?limit=1000"),
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
        _cartItems = data['data'] ?? [];
        _calculateCartTotal();
        notifyListeners();
      } else {
        errorMessage = 'Failed to load cart data';
        notifyListeners();
      }
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners(); // Notify again to update loading state
    }
  }

  void _calculateCartTotal() {
    _cartTotal = 0.0;
    for (var item in _cartItems) {
      final price = double.tryParse(item['productVariant']['price'] ?? '0') ?? 0.0;
      final quantity = item['quantity'] ?? 0;
      _cartTotal += price * quantity;
    }
  }

  Future<void> addToCart(context, int id, {required int quantity}) async {
    isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> payload = {
        'product_variant': id,
        'quantity': quantity,
      };

      final response = await TokenManager.instance.authenticatedRequest(
            (token) => http.post(
          Uri.parse(StringConst.protocol +
              StringConst.baseUrl +
              StringConst.addToCart),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ),
        context,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Added to cart successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        log("Product added to cart successfully.");
        await fetchCartData(context); // Refresh cart data after adding item
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['errors']?['nonFieldErrors'] ??
            'Failed to add product';
        Fluttertoast.showToast(
          msg: "$errorMessage",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        log("Failed to add product: $errorMessage");
      }
    } catch (error) {
      log("Internal Server Error. Please Contact IT manager !!!");
      Fluttertoast.showToast(
        msg: "Internal Server Error. Please Contact IT manager !!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItemQuantity(int itemId, int newQuantity, BuildContext context) async {
    isUpdatingQuantity[itemId] = true;
    notifyListeners();

    try {
      Map<String, dynamic> payload = {
        'quantity': newQuantity,
      };

      final response = await TokenManager.instance.authenticatedRequest(
            (token) => http.patch(
          Uri.parse("${StringConst.protocol}${StringConst.baseUrl}${StringConst.addToCart}$itemId/"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ),
        context,
      );

      if (response.statusCode == 200) {
        final itemIndex = _cartItems.indexWhere((item) => item['id'] == itemId);
        if (itemIndex != -1) {
          _cartItems[itemIndex]['quantity'] = newQuantity;

          // Update total price based on the new quantity
          String unitPrice = _cartItems[itemIndex]['productVariant']['price'] ?? '0';
          double totalPrice = double.parse(unitPrice) * newQuantity;
          _cartItems[itemIndex]['totalPrice'] = totalPrice;

          _calculateCartTotal();
          notifyListeners();
        }
      } else {
        log("Failed to update quantity: ${response.body}");
      }
    } catch (error) {
      log("Error updating quantity: $error");
    } finally {
      isUpdatingQuantity[itemId] = false;
      notifyListeners();
    }
  }

  bool isItemUpdating(int itemId) {
    return isUpdatingQuantity[itemId] ?? false;
  }

  Future<void> removeCartItem(int itemId, context) async {
    // Indicate that an item is being removed
    isUpdatingQuantity[itemId] = true;
    notifyListeners();

    try {
      final response = await TokenManager.instance.authenticatedRequest(
            (token) => http.delete(
          Uri.parse(
              "${StringConst.protocol}${StringConst.baseUrl}${StringConst.addToCart}$itemId/"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        context,
      );

      if (response.statusCode == 200) {
        // Remove the item from the local cart items list
        _cartItems.removeWhere((item) => item['id'] == itemId);
        _calculateCartTotal();

        Fluttertoast.showToast(
          msg: "Removed from cart successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        log("Product removed from cart successfully.");

        await fetchCartData(context); // Fetch latest cart items after removal
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['errors']?['nonFieldErrors'] ??
            'Failed to remove product';
        Fluttertoast.showToast(
          msg: "$errorMessage",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        log("Failed to remove product: $errorMessage");
      }
    } catch (error) {
      log("Error removing item: $error");
      Fluttertoast.showToast(
        msg: "Internal Server Error. Please Contact IT manager !!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.mainAppColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      isUpdatingQuantity[itemId] = false;
      notifyListeners(); // Notify listeners to update the UI after removing item
    }
  }
}