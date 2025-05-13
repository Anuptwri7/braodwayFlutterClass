import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/wholeseller_view/provider/admin_product_provider.dart';

class WholeSellerProductPage extends StatefulWidget {
  const WholeSellerProductPage({super.key});

  @override
  State<WholeSellerProductPage> createState() => _WholeSellerProductPageState();
}

class _WholeSellerProductPageState extends State<WholeSellerProductPage> {
  String _searchQuery = "";
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();

    // Initial product fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProductProvider>(context, listen: false).fetchProducts(context: context);
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = Provider.of<AdminProductProvider>(context, listen: false);

    // Check if we're near the bottom and can load more products
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !provider.isLoading &&
        provider.hasMoreProducts) {
      provider.fetchProducts(searchQuery: _searchQuery, loadMore: true,context: context);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProductProvider = Provider.of<AdminProductProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(adminProductProvider),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<AdminProductProvider>(
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
                    return Center(child: Text(provider.errorMessage!));
                  }
                  if (provider.products.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found.",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return _buildProductGrid(provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AdminProductProvider adminProductProvider) {
    return Container(
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
                  top: 40.0,
                  left: 50.0,
                  right: 15.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const[
                      Expanded(
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
                      SizedBox(width: 50), // Placeholder width
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 20.0,
                  right: 20.0,
                  child: _buildSearchSection(adminProductProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(AdminProductProvider adminProductProvider) {
    return TextField(
      controller: _controller,
      style: const TextStyle(
        fontFamily: "Poppins",
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Search Products...',
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontFamily: "Poppins",
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.mainAppColor.withOpacity(0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.mainAppColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onChanged: (String value) {
        setState(() {
          _searchQuery = value;
        });
        _debouncer.run(() {
          adminProductProvider.fetchProducts(
            searchQuery: _searchQuery,
            context: context,
          );
        });
      },
    );
  }

  Widget _buildProductGrid(AdminProductProvider provider) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final product = provider.products[index];
                  return _buildProductCard(product);
                },
                childCount: provider.products.length,
              ),
            ),
          ),
          if (provider.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: AppColors.mainAppColor,
                    size: 40,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: product['shopifyImageUrl'] == null ||
                  product['shopifyImageUrl'] == 'nan'
                  ? Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              )
                  : Image.network(
                product['shopifyImageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.mainAppColor,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'No Name',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (product['productVariants'] != null && product['productVariants'].isNotEmpty && product['productVariants'][0]['price'] != null)
                      ? "\$${product['productVariants'][0]['price']}"
                      : 'N/A',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: AppColors.mainAppColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}