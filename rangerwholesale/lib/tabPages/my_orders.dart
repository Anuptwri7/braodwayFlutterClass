import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../const/styleConst.dart';
import '../provider/order_provider.dart';
import 'orders_details.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.getOrders(context, null, null, refresh: true);
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final threshold = 0.8; // Load more when 80% scrolled

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final triggerFetch = currentScroll >= (threshold * maxScroll);

      if (triggerFetch && !orderProvider.isLoading && orderProvider.hasMoreData) {
        orderProvider.getOrders(
          context,
          _searchController.text.isEmpty ? null : _searchController.text,
          _selectedCategory,
        );
      }
    });
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.getOrders(
        context,
        value.isEmpty ? null : value,
        _selectedCategory,
        refresh: true,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
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
          // Back button and title
          Positioned(
            top: 35.0,
            left: 15.0,
            right: 15.0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 25),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Orders",
                      style: TextStyle(
                        fontFamily: "poppins",
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search orders...',
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.search, color: AppColors.mainAppColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetails(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 10),
                _buildOrderDetails(order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            order['uniqueCode']?.toString() ?? '',
            style: const TextStyle(
              fontFamily: "poppins",
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          (order['status']?.toString() ?? '').toUpperCase(),
          style: TextStyle(
            fontFamily: "poppins",
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: _getStatusColor(order['status']?.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order) {
    final userDetails = order['userDetails'] as Map<String, dynamic>?;
    final shippingAddress = order['shippingAddress'] as Map<String, dynamic>?;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userDetails?['fullName']?.toString() ?? '',
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                shippingAddress?['name']?.toString() ?? '',
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                shippingAddress?['mobile']?.toString() ?? '',
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          'Price: ${_formatPrice(order['price'])}',
          style: TextStyle(
            fontFamily: "poppins",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'self-picked':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      default:
        return AppColors.mainAppColor;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    try {
      return double.parse(price.toString()).toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  if (orderProvider.orders.isEmpty && orderProvider.isLoading) {
                    return Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color: AppColors.mainAppColor,
                        size: 40,
                      ),
                    );
                  }

                  if (orderProvider.orders.isEmpty && !orderProvider.isLoading) {
                    return const Center(
                      child: Text(
                        "No Orders Found",
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: orderProvider.orders.length +
                          (orderProvider.isLoading || orderProvider.hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < orderProvider.orders.length) {
                          return _buildOrderCard(orderProvider.orders[index]);
                        } else if (orderProvider.isLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: AppColors.mainAppColor,
                                size: 30,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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