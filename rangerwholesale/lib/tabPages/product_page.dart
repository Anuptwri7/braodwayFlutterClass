import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/cart_provider.dart';
import '../provider/product_provider.dart';
import '../const/styleConst.dart';

class ProductPage extends StatefulWidget {
  final int? id;

  const ProductPage({Key? key, this.id}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.clearProducts();
      _fetchInitialProducts();
      _scrollController.addListener(_onScroll);
    });
  }

  void _fetchInitialProducts() {
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      widget.id,
      context: context,
    );
  }

  void _onScroll() {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!provider.isLoading && provider.hasNextPage) {
        provider.loadMore(context);
      }
    }
  }

  void _performSearch(String query) {
    _debouncer.run(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(
        widget.id,
        searchQuery: query,
        context: context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(40.0),
                        bottomLeft: Radius.circular(40.0),
                      ),
                      color: AppColors.mainAppColor,
                    ),
                    height: 200.0,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: 35.0,
                          left: 15.0,
                          right: 80.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white, size: 25),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    "Products",
                                    style: TextStyle(
                                        fontFamily: "poppins",
                                        color: Colors.white,
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 20.0,
                          left: 20.0,
                          right: 20.0,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search Products...',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.search),
                                  ),
                                  onChanged: _performSearch,
                                ),
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
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.products.isEmpty) {
                    return Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color: AppColors.mainAppColor,
                        size: 40,
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (provider.products.isEmpty) {
                    return const Center(
                      child: Text('No products found'),
                    );
                  }

                  return NotificationListener<OverscrollIndicatorNotification>(
                    onNotification:
                        (OverscrollIndicatorNotification overscroll) {
                      overscroll.disallowIndicator();
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: provider.products.length +
                          (provider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.products.length) {
                          return Center(
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: AppColors.mainAppColor,
                              size: 40,
                            ),
                          );
                        }
                        final product = provider.products[index];
                        return ProductCard(product: product);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final dynamic product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();
  List<dynamic> _variants = [];

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1';
    _initializeVariants();
  }

  void _initializeVariants() {
    if (widget.product['productVariants'] != null) {
      _variants = List.from(widget.product['productVariants']);
    }
  }

  void _updateQuantity(int change) {
    int currentValue = int.tryParse(_quantityController.text) ?? 1;
    int newValue = (currentValue + change).clamp(1, 99);
    _quantityController.text = newValue.toString();
    _quantityFocusNode.unfocus();
  }

  Widget _buildProductCard(dynamic variant) {
    final productName = widget.product['name'] ?? 'Unknown Product';
    final productImage = widget.product['shopifyImageUrl'];
    final variantTitle = variant['title'] ?? '';
    final displayName = _variants.length > 1 ? '$productName - $variantTitle' : productName;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: productImage != null && productImage != 'nan'
                    ? Image.network(
                  productImage,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  height: 180,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${variant['price'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainAppColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Quantity and Add to Cart Row
                Row(
                  children: [
                    // Compact Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _updateQuantity(-1),
                            color: AppColors.mainAppColor,
                            iconSize: 20,
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _quantityController,
                              focusNode: _quantityFocusNode,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  int? parsed = int.tryParse(value);
                                  if (parsed == null || parsed < 1) {
                                    _quantityController.text = '1';
                                    _quantityController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: _quantityController.text.length),
                                    );
                                  }
                                }
                              },
                              onEditingComplete: () {
                                if (_quantityController.text.isEmpty) {
                                  _quantityController.text = '1';
                                }
                              },
                              onSubmitted: (value) {
                                if (value.isEmpty || int.tryParse(value) == null || int.parse(value) < 1) {
                                  _quantityController.text = '1';
                                }
                                _updateQuantity(0);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _updateQuantity(1),
                            color: AppColors.mainAppColor,
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Compact Add to Cart Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          if (prefs.getBool("is_verified_by_admin") == false) {
                            Fluttertoast.showToast(
                              msg: "You need to verify your account to add products to the cart",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                            return;
                          }
                          final quantity = int.tryParse(_quantityController.text) ?? 1;
                          final productVariantId = variant['id'];

                          // Use CartProvider to add the item to the cart
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addToCart(context, productVariantId, quantity: quantity);
                        },
                        icon: const Icon(Icons.shopping_cart, size: 20),
                        label: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_variants.length <= 1) {
      return _buildProductCard(_variants.isNotEmpty ? _variants[0] : null);
    }

    return Column(
      children: _variants.map((variant) => _buildProductCard(variant)).toList(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }
}


class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}