import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/provider/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/featured_product_provider.dart';
import '../const/styleConst.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = "";
  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _searchQuery = "";
    _searchController.clear();
    // Fetch featured products when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final featuredProductProvider =
      Provider.of<FeaturedProductProvider>(context, listen: false);

      featuredProductProvider.fetchFeaturedProducts(searchQuery: "", context: context);

      // Add listener to the scroll controller for pagination
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50) {
          if (!featuredProductProvider.isLoading && featuredProductProvider.hasNextPage) {
            featuredProductProvider.loadMoreFeaturedProducts(searchQuery: _searchQuery,context: context);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
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
                          top: 45.0,
                          left: 60.0,
                          right: 80.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Featured Products",
                                    style: TextStyle(
                                        fontFamily: "poppins",
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
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
                                child:TextField(
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
                                  onChanged: (String value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                    _debouncer(() {
                                      Provider.of<FeaturedProductProvider>(context, listen: false)
                                          .fetchFeaturedProducts(searchQuery: _searchQuery,context: context);
                                    });
                                  },
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
              child: Consumer<FeaturedProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.featuredProducts.isEmpty) {
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

                  if (provider.featuredProducts.isEmpty) {
                    return const Center(
                      child: Text('No featured products found'),
                    );
                  }

                  return NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (OverscrollIndicatorNotification overscroll) {
                      overscroll.disallowIndicator();
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: provider.featuredProducts.length +
                          (provider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.featuredProducts.length) {
                          return Center(
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: AppColors.mainAppColor,
                              size: 40,
                            ),
                          );
                        }
                        final product = provider.featuredProducts[index];
                        return FeaturedProductCard(product: product);
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

class FeaturedProductCard extends StatefulWidget {
  final dynamic product;

  const FeaturedProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _FeaturedProductCardState createState() => _FeaturedProductCardState();
}

class _FeaturedProductCardState extends State<FeaturedProductCard> {
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1';
  }

  void _updateQuantity(int change) {
    int currentValue = int.tryParse(_quantityController.text) ?? 1;
    int newValue = (currentValue + change).clamp(1, 99999);
    _quantityController.text = newValue.toString();
    _quantityFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final productName = widget.product['name'] ?? 'Unknown Product';
    final productImage = widget.product['shopifyImageUrl'];

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
          // Product Image and Favorite Button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: productImage != null
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
              )
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
                        productName,
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
                      (widget.product['productVariants'] != null && widget.product['productVariants'].isNotEmpty)
                          ? '\$${widget.product['productVariants'][0]['price'] ?? 'N/A'}'
                          : 'N/A',
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
                                // Allow clearing input temporarily while typing
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
                                // Set default value of '1' if empty when editing completes
                                if (_quantityController.text.isEmpty) {
                                  _quantityController.text = '1';
                                }
                              },
                              onSubmitted: (value) {
                                // Ensure proper value is submitted
                                if (value.isEmpty || int.tryParse(value) == null || int.parse(value) < 1) {
                                  _quantityController.text = '1';
                                }
                                // Optional: You can trigger actions like updating quantity here
                                _updateQuantity(0); // Use a neutral update for any additional logic
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
                          //make the keyboard go away
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
                          // Ensure proper quantity is used during submission
                          final quantity = int.tryParse(_quantityController.text) ?? 1;
                          final productVariantId = widget.product['productVariants'][0]['id'];

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

  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}