import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/tabPages/notification_page.dart';
import 'package:rangerwholesale/tabPages/product_details.dart';
import '../const/styleConst.dart';
import '../provider/product_provider.dart';

class ProductPage extends StatefulWidget {
  bool show;
  ProductPage({super.key, required this.show});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchProducts(null,context: context);
    });
  }

  String _searchQuery = "";
  String _selectedCategory = 'All';
  List<String> _selectedBrands = [];
  String _sortBy = 'Popular';

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
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
                            Visibility(
                              visible: widget.show,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white, size: 25),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            // IconButton(
                            //   icon: const Icon(Icons.notifications,
                            //       color: Colors.white, size: 25),
                            //   onPressed: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(builder: (context) => const NotificationPage()),
                            //     );
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
                                    onSubmitted: (String value) {
                                      productProvider.fetchProducts(
                                        null,
                                        searchQuery:
                                            value,
                                        context: context// Trigger search on submit
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(width: 8),
                            // Expanded(
                            //   flex: 2,
                            //   child: GestureDetector(
                            //     onTap: () => _showFilterDialog(context),
                            //     child: Container(
                            //       height: 50,
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(10),
                            //         color: Colors.white,
                            //       ),
                            //       child: const Center(
                            //         child: Icon(Icons.tune, color: AppColors.mainAppColor),
                            //       ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("All Products", style: TextStyle(fontFamily: "poppins",color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          productProvider.isLoading
              ? Expanded(
                child: Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColors.mainAppColor,
                      size: 40,
                    ),
                  ),
              ) // Show a loader while fetching
              : Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns in the grid
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.6, // Adjust the aspect ratio of each card
              ),
              itemCount: productProvider.products?.length ?? 0,
              itemBuilder: (context, index) {
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
                    color: Colors.white, // Card background color
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name in the top-left corner
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              product.name ?? "No name",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff4c4c4c), // Dark color for contrast
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Centered product image without shadow
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: product.image != null
                                ? Image.network(
                              product.image!,
                              fit: BoxFit.contain,
                              height: 180, // Adjusted height for larger image
                            )
                                : const Icon(
                              Icons.image,
                              size: 80,
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
        ],
      ),
    );
  }
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _selectedBrands = [];
                        _sortBy = 'Popular';
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.mainAppColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        'All',
                        'Electronics',
                        'Clothing',
                        'Books',
                        'Home',
                        'Sports'
                      ]
                          .map((category) => ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // Brands
                    const Text(
                      'Brands',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: ['Nike', 'Adidas', 'Apple', 'Samsung', 'Sony']
                          .map((brand) => FilterChip(
                        label: Text(brand),
                        selected: _selectedBrands.contains(brand),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedBrands.add(brand);
                            } else {
                              _selectedBrands.remove(brand);
                            }
                          });
                        },
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // Sort By
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Popular',
                        'Newest',
                        'Price: Low to High',
                        'Price: High to Low'
                      ]
                          .map((sort) => ChoiceChip(
                        label: Text(sort),
                        selected: _sortBy == sort,
                        onSelected: (selected) {
                          setState(() {
                            _sortBy = sort;
                          });
                        },
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainAppColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
