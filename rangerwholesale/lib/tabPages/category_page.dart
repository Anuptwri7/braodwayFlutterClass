import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/provider/category_provider.dart';
import 'package:rangerwholesale/tabPages/product_page.dart';
import '../const/styleConst.dart';
import '../model/category_lisiting_model.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _searchController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    final provider = Provider.of<CategoryListingProvider>(context, listen: false);
    provider.resetState();
    _searchController.clear(); // Clear search controller on initialization
    await provider.fetchCategories(context);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<CategoryListingProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!provider.isLoadingMore) {
        provider.fetchCategories(context, loadMore: true);
      }
    }
  }

  void _handleSearch(String query) {
    _debouncer.run(() {
      if (mounted) {
        final provider = Provider.of<CategoryListingProvider>(context, listen: false);
        provider.fetchCategories(context, searchQuery: query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
          Provider.of<CategoryListingProvider>(context, listen: false).clearSearch(context);
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Column(
            children: [
              _buildHeader(),
              _buildCategoryGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: Container(
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
          children: [
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
                        "Collections",
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
              child: _buildSearchField(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search Collections...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            Provider.of<CategoryListingProvider>(context, listen: false)
              ..clearSearch(context)
              ..fetchCategories(context);
          },
        )
            : null,
      ),
      onChanged: _handleSearch,
    );
  }

  Widget _buildCategoryGrid() {
    return Expanded(
      child: Consumer<CategoryListingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.categories.isEmpty) {
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

          if (provider.categories.isEmpty) {
            return const Center(
              child: Text('No categories found'),
            );
          }

          return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return false;
            },
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      return CategoryCard(category: provider.categories[index]);
                    },
                  ),
                ),
                if (provider.isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColors.mainAppColor,
                      size: 40,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Data category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log(category.id.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(id: category.id),
          ),
        ).then((_) {
          Provider.of<CategoryListingProvider>(context, listen: false).clearSearch(context);
        });
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: _buildCategoryImage(),
              ),
              _buildCategoryName(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (category.shopifyImageUrl != null) {
      return Image.network(
        category.shopifyImageUrl!,
        height: 120,
        width: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
      );
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.category,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCategoryName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
      child: Text(
        category.name ?? 'Unnamed Category',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
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