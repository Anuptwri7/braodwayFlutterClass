import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/tabPages/product_details.dart';

import '../const/styleConst.dart';
import '../provider/product_provider.dart';

class CategoryProduct extends StatefulWidget {
  String categoryName;
  int categoryId;
  CategoryProduct({super.key, required this.categoryName, required this.categoryId});

  @override
  _CategoryProductState createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchProducts(widget.categoryId,context: context); // Fetch by categoryId
    });

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
        Provider.of<ProductProvider>(context, listen: false).loadMore(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
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
                        left: 10.0,
                        right: 15.0,
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
                            // IconButton(
                            //   onPressed: () {},
                            //   icon: Icon(Icons.search_outlined,
                            //       color: Colors.white, size: 25),
                            // ),
                            // IconButton(
                            //   icon: const Icon(Icons.notifications,
                            //       color: Colors.white, size: 25),
                            //   onPressed: () {
                            //     // Implement notification logic here
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20.0,
                        left: 20.0,
                        right: 20.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 10,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _controller,
                                    decoration: const InputDecoration(
                                      hintText: 'Search...',
                                      border: InputBorder.none,
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (String value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                      productProvider.fetchProducts(
                                        null,
                                        searchQuery:
                                            _searchQuery,
                                        context: context// Pass search query
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(width: 8),
                            // Expanded(
                            //   flex: 2,
                            //   child: Container(
                            //     height: 50,
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(10),
                            //       color: Colors.white,
                            //     ),
                            //     child: Center(
                            //       child:
                            //           Image.asset("assets/icons/setting.png"),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.categoryName,
                style: const TextStyle(
                  fontFamily: "poppins",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          if (productProvider.isLoading && productProvider.products!.isEmpty)
            Expanded(
              child: Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.mainAppColor,
                  size: 40,
                ),
              ),
            ),

          if (productProvider.errorMessage != null)
            Center(child: Text(productProvider.errorMessage!)),

          if (!productProvider.isLoading &&
              productProvider.errorMessage == null &&
              productProvider.products != null &&
              productProvider.products!.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No products available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          if (!productProvider.isLoading &&
              productProvider.errorMessage == null &&
              productProvider.products != null &&
              productProvider.products!.isNotEmpty)
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
                    productProvider.loadMore(context); // Fetch more when scrolled to the bottom
                  }
                  return false;
                },
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5 / 4,
                  ),
                  itemCount: productProvider.hasNextPage
                      ? productProvider.products!.length + 1
                      : productProvider.products!.length,
                  itemBuilder: (context, index) {
                    if (index == productProvider.products!.length) {
                      return productProvider.isLoading
                          ? Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppColors.mainAppColor,
                          size: 40,
                        ),
                      )
                          : const SizedBox(); // Empty widget if not loading
                    }

                    final product = productProvider.products![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(product: product),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        elevation: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
                              child: Text(
                                product.name ?? "No name",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: product.image != null
                                    ? Image.network(
                                  product.image!,
                                  fit: BoxFit.contain,
                                  height: 180,
                                )
                                    : const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
