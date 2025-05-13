import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/provider/getAddressProvider.dart';
import 'package:rangerwholesale/provider/order_provider.dart';
import '../model/addressModel.dart';
import '../provider/cart_provider.dart';
import '../const/styleConst.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _deliveryMethod = 'delivery';
  Timer? _debounceTimer;
  bool _isUpdatingQuantity = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCartData(context);
      Provider.of<AddressProviderGet>(context, listen: false).fetchAddress(context);
    });
  }

  Future<void> _handleQuantityUpdate(int cartItemId, int newQuantity) async {
    setState(() {
      _isUpdatingQuantity = true;
    });

    try {
      await Provider.of<CartProvider>(context, listen: false)
          .updateCartItemQuantity(cartItemId, newQuantity, context);
    } finally {
      setState(() {
        _isUpdatingQuantity = false;
      });
    }
  }

  List<int> prepareCartData(CartProvider cartProvider) {
    List<int> cartItemsData = [];
    for (var item in cartProvider.cartItems) {
      cartItemsData.add(item['id']);
    }
    return cartItemsData;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                "Shopping Cart",
                style: TextStyle(
                  fontFamily: "poppins",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
            body: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.isLoading) {
                  return Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColors.mainAppColor,
                      size: 40,
                    ),
                  );
                }
                if (cartProvider.errorMessage != null) {
                  return Center(
                    child: Text(
                      cartProvider.errorMessage!,
                      style: const TextStyle(
                        fontFamily: "poppins",
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                if (cartProvider.cartItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: AppColors.mainAppColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Your cart is empty",
                          style: TextStyle(
                            fontFamily: "poppins",
                            fontSize: 20,
                            color: AppColors.mainAppColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Consumer<AddressProviderGet>(
                  builder: (context, addressProvider, child) {
                    if (addressProvider.isLoading) {
                      return Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppColors.mainAppColor,
                          size: 40,
                        ),
                      );
                    }
                    if (addressProvider.addressListing?.data == null || addressProvider.addressListing!.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No address found',
                          style: TextStyle(
                            fontFamily: "poppins",
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    Data addressData = addressProvider.addressListing!.data![0];
                    return Column(
                      children: [
                        Expanded(
                          child: NotificationListener<
                              OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowIndicator();
                              return false;
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: cartProvider.cartItems.length,
                              itemBuilder: (context, index) {
                                final cartItem = cartProvider.cartItems[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.08),
                                        spreadRadius: 2,
                                        blurRadius: 15,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(15),
                                                child: Stack(
                                                  children: [
                                                    cartItem['productVariant']['product']['shopifyImageUrl'] != null &&
                                                        cartItem['productVariant']['product']['shopifyImageUrl'] != 'nan'
                                                        ? Image.network(
                                                      cartItem['productVariant']['product']['shopifyImageUrl'],
                                                      width: 120,
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        color: Colors.grey[200],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.image_not_supported,
                                                            size: 50,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                        : Container(
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.image_not_supported,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                        LinearGradient(
                                                          begin: Alignment.topCenter,
                                                          end: Alignment.bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black.withOpacity(0.2),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    cartItem['productVariant']['product']['name'] ?? 'Product Name',
                                                    style: const TextStyle(
                                                      fontFamily: "poppins",
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.mainAppColor.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    child: Text(
                                                      "\$${double.tryParse(cartItem['productVariant']['price'] ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
                                                      style: const TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.mainAppColor,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[50],
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.grey[200]!),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        _buildQuantityButton(
                                                          icon: Icons.remove_rounded,
                                                          onPressed: () async {
                                                            if (cartItem['quantity'] > 1) {
                                                              await _handleQuantityUpdate(
                                                                cartItem['id'],
                                                                cartItem['quantity'] - 1,
                                                              );
                                                            }
                                                          },
                                                          isLeft: true,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            _showQuantityInputDialog(
                                                              context,
                                                              cartItem['quantity'],
                                                                  (int newQuantity) {
                                                                Provider.of<CartProvider>(
                                                                    context,
                                                                    listen: false)
                                                                    .updateCartItemQuantity(
                                                                  cartItem['id'],
                                                                  newQuantity, context,
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                            width: 60,
                                                            height: 44,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              border: Border.symmetric(
                                                                horizontal: BorderSide(color: Colors.grey[200]!),
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                '${cartItem['quantity']}',
                                                                style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontFamily: "poppins",
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        _buildQuantityButton(
                                                          icon: Icons.add_rounded,
                                                          onPressed: () async {
                                                            if (cartItem['quantity'] < 99999) {
                                                              await _handleQuantityUpdate(
                                                                cartItem['id'],
                                                                cartItem['quantity'] + 1,
                                                              );
                                                            }
                                                          },
                                                          isLeft: false,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 7,
                                        right: 5,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(20),
                                            onTap: () => _showRemoveConfirmationBottomSheet(context, cartItem),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.mainAppColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.close_rounded,
                                                  color: Colors.grey[100],
                                                  size: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // if (cartProvider.isItemUpdating(cartItem['id']))
                                      //   Positioned.fill(
                                      //     child: Container(
                                      //       color: Colors.white.withOpacity(0.7),
                                      //       child: Center(
                                      //         child: SizedBox(
                                      //           width: 24,
                                      //           height: 24,
                                      //           child: CircularProgressIndicator(
                                      //             valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainAppColor),
                                      //             strokeWidth: 2,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_deliveryMethod == 'delivery')
                                _buildAddressCard(addressData),
                              const SizedBox(height: 16),
                              const Text(
                                "Delivery Method",
                                style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDeliveryOption(
                                      title: "Delivery",
                                      icon: Icons.local_shipping,
                                      isSelected: _deliveryMethod == 'delivery',
                                      onTap: () => setState(
                                              () => _deliveryMethod = 'delivery'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDeliveryOption(
                                      title: "Self Pickup",
                                      icon: Icons.store,
                                      isSelected:
                                      _deliveryMethod == 'self-pick',
                                      onTap: () => setState(
                                              () => _deliveryMethod = 'self-pick'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Amount",
                                    style: TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "\$${cartProvider.cartTotal.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.mainAppColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showOrderConfirmationDialog(context, () {
                                      _submitOrder(context);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.mainAppColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Place Order",
                                    style: TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (_isUpdatingQuantity)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LoadingAnimationWidget.threeArchedCircle(
                          color: AppColors.mainAppColor,
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Updating Cart...",
                          style: TextStyle(
                            fontFamily: "poppins",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required Function() onPressed,
    required bool isLeft,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (!_isUpdatingQuantity) {
            await onPressed();
          }
        },
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(isLeft ? 12 : 0),
          right: Radius.circular(isLeft ? 0 : 12),
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(isLeft ? 12 : 0),
              right: Radius.circular(isLeft ? 0 : 12),
            ),
          ),
          child: Icon(
            icon,
            color: _isUpdatingQuantity ? Colors.grey : AppColors.mainAppColor,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.mainAppColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.mainAppColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.mainAppColor : Colors.grey[600],
              size: 15,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.mainAppColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityInputDialog(BuildContext context, int currentQuantity, Function(int) onConfirm) {
    final TextEditingController controller = TextEditingController(text: currentQuantity.toString());

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainAppColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.mainAppColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter Quantity',
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                      hintText: 'Enter quantity',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: "poppins",
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: "poppins",
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: "poppins",
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newQuantity = int.tryParse(controller.text);
                          if (newQuantity != null && newQuantity > 0 && newQuantity <= 99999) {
                            onConfirm(newQuantity);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: "poppins",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressCard(Data addressData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addressData.city!.toUpperCase(),
            style: const TextStyle(
              fontFamily: "poppins",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mainAppColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildAddressDetail(
            icon: Icons.phone,
            text: addressData.mobile ?? 'No Mobile Number',
          ),
          const SizedBox(height: 8),
          _buildAddressDetail(
            icon: Icons.location_on,
            text:
            "${addressData.city}, ${addressData.pincode}, ${addressData.state}",
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetail({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "poppins",
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  void _submitOrder(BuildContext context) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      List<int> cartItemsData = prepareCartData(cartProvider);
      final addressProvider =
      Provider.of<AddressProviderGet>(context, listen: false);
      int? addressId = addressProvider.addressListing!.data![0].id;
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      await orderProvider.placeOrder(
        context: context,
        selfPicked: _deliveryMethod == 'self-pick' ? "self-pick" : null,
        cartItems: cartItemsData,
        shippingAddressId: addressId.toString(),
      );
    } catch (error) {
      log(error.toString());
    }
  }

  void _showRemoveConfirmationBottomSheet(BuildContext context, Map<String, dynamic> cartItem) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Remove Item',
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cartItem['productVariant']['product']['shopifyImageUrl'] ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem['productVariant']['product']['name'] ?? "Product Name",
                            style: const TextStyle(
                              fontFamily: "poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Remove this item from your cart?',
                            style: TextStyle(
                              fontFamily: "poppins",
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return Expanded(
                        child: ElevatedButton(
                          onPressed: cartProvider.isItemUpdating(cartItem['id'])
                              ? null
                              : () async {
                            await Provider.of<CartProvider>(context, listen: false)
                                .removeCartItem(cartItem['id'], context);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: cartProvider.isItemUpdating(cartItem['id'])
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: AppColors.mainAppColor,
                              size: 40,
                            ),
                          )
                              : const Text(
                            'Remove',
                            style: TextStyle(
                              fontFamily: "poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showOrderConfirmationDialog(BuildContext context, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.mainAppColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.mainAppColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to place this order?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                  color: AppColors.mainAppColor),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: "poppins",
                              fontSize: 16,
                              color: AppColors.mainAppColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainAppColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontFamily: "poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}