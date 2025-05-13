import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/provider/retailerForFilter.dart';
import 'package:rangerwholesale/wholeseller_view/provider/wholeseller_order_provider.dart';
import 'package:rangerwholesale/wholeseller_view/wholeSeller_order_detail_page.dart';

class WholeSellerOrderPage extends StatefulWidget {
  final bool show;
  const WholeSellerOrderPage({Key? key, required this.show}) : super(key: key);

  @override
  State<WholeSellerOrderPage> createState() => _WholeSellerOrderPageState();
}

class _WholeSellerOrderPageState extends State<WholeSellerOrderPage> {
  String? selectedRetailerId;
  String? selectedStatus;
  String? selectedModeOfDelivery;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Use Future.microtask to schedule the provider calls after the build
    Future.microtask(() {
      if (mounted) {
        final provider = Provider.of<WholeSellerOrderProvider>(context, listen: false);
        provider.resetFilters(context);
        provider.resetState();
        provider.fetchWholeSellerOrders(context);
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (mounted) {
        final provider = Provider.of<WholeSellerOrderProvider>(context, listen: false);
        if (!provider.isLoading && provider.hasMoreData) {
          provider.loadMoreOrders(context);
        }
      }
    }
  }

  void _handleSearch(String query) {
    setState(() => _isSearching = query.isNotEmpty);
    _debouncer.run(() {
      if (mounted) {
        final provider = Provider.of<WholeSellerOrderProvider>(context, listen: false);
        provider.searchOrders(query,context);
      }
    });
  }

  final Map<int, bool> _updatingStates = {};

  Future<void> _showDeliveryStatusDialog(String mode, int orderId) async {
    _updatingStates[orderId] = false;

    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: _buildStatusDialogContent(mode, orderId, setState),
        ),
      ),
    );
  }

  Widget _buildStatusDialogContent(String mode, int orderId, StateSetter setDialogState) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            mode == 'self-pick' ? Icons.store : Icons.local_shipping,
            size: 50,
            color: AppColors.mainAppColor,
          ),
          const SizedBox(height: 20),
          Text(
            mode == 'self-pick' ? 'Is the item self-picked?' : 'Is the item delivered?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "poppins",
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _updatingStates[orderId] == true
              ? LoadingAnimationWidget.threeArchedCircle(
            color: AppColors.mainAppColor,
            size: 40,
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _updatingStates[orderId] == true ? null : () => Navigator.pop(context),
                child: const Text('No', style: TextStyle(color: Colors.black87, fontFamily: "poppins")),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainAppColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _updatingStates[orderId] == true
                    ? null
                    : () async {
                  if (!mounted) return;

                  setDialogState(() {
                    _updatingStates[orderId] = true;
                  });

                  await context
                      .read<WholeSellerOrderProvider>()
                      .updateOrderStatus(orderId, mode);

                  if (mounted) {
                    setState(() {
                      _updatingStates[orderId] = false;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Yes', style: TextStyle(color: Colors.white, fontFamily: "poppins")),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WholeSellerOrderDetail(order: order)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(order),
              Divider(color: Colors.grey.shade200),
              _buildOrderDetails(order),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildOrderHeader(dynamic order) {
    final status = order['status'];
    final statusColor = status == "self-picked"
        ? Colors.teal
        : status == "delivered"
        ? Colors.green
        : AppColors.mainAppColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${order['uniqueCode'] ?? 'N/A'}',
            style: const TextStyle(
              fontFamily: "poppins",
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (status == "pending")
          IconButton(
            icon: Icon(
              Icons.touch_app,
              color: statusColor,
              size: 30,
            ),
            onPressed: () => _showDeliveryStatusDialog(
              order['modeOfDelivery'] ?? '',
              order['id'],
            ),
          ),
      ],
    );
  }

  Widget _buildOrderDetails(dynamic order) {
    final status = order['status'];
    final statusColor = status == "self-picked"
        ? Colors.teal
        : status == "delivered"
        ? Colors.green
        : AppColors.mainAppColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                Icons.person_outline,
                order['userDetails']?['fullName'] ?? 'N/A',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.location_on_outlined,
                order['shippingAddress']['name'] ?? 'N/A',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.phone_outlined,
                order['shippingAddress']['mobile'] ?? 'N/A',
                isPhone: true,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 14,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Price: \$${double.tryParse(order['price'].toString())?.toStringAsFixed(2) ?? 'N/A'}',
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {bool isPhone = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isPhone ? AppColors.mainAppColor : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "poppins",
              fontSize: 14,
              color: isPhone ? AppColors.mainAppColor : Colors.grey.shade700,
              fontWeight: isPhone ? FontWeight.w500 : FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            _buildHeader(),
            _buildOrderList(),
          ],
        ),
      ),
    );
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
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 5,
                  right: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.show)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
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
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search orders...',
                              hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: "poppins"),
                              prefixIcon: Icon(Icons.search, color: AppColors.mainAppColor.withOpacity(0.7)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onChanged: _handleSearch,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _showFilterDialog(context);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Icon(Icons.tune,
                                  color: AppColors.mainAppColor),
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
        ],
      ),
    );
  }

  Widget _buildRetailerDropdown(RetailerForFilterProvider retailerProvider, StateSetter setState) {
    // First, verify if the selectedRetailerId exists in the current retailers list
    bool selectedValueExists = selectedRetailerId == null ||
        retailerProvider.retailers.any((retailer) => retailer['id'].toString() == selectedRetailerId);

    // If selected value doesn't exist in the list, reset it
    if (!selectedValueExists) {
      selectedRetailerId = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValueExists ? selectedRetailerId : null,
              hint: const Text(
                'Select Retailer',
                style: TextStyle(fontFamily: "poppins"),
              ),
              menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
              onTap: () async {
                if (retailerProvider.retailers.isEmpty) {
                  await retailerProvider.fetchRetailers(
                    refresh: true,
                    context: context,
                  );
                }
              },
              onChanged: (value) {
                setState(() {
                  selectedRetailerId = value;
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'All Retailers',
                    style: TextStyle(fontFamily: "poppins"),
                  ),
                ),
                if (retailerProvider.isLoading && retailerProvider.retailers.isEmpty)
                  const DropdownMenuItem<String>(
                    enabled: false,
                    value: 'loading', // Unique value for loading state
                    child: Text(
                      'Loading retailers...',
                      style: TextStyle(fontFamily: "poppins", color: Colors.grey),
                    ),
                  ),
                // Use Set to ensure unique retailer IDs
                ...{...retailerProvider.retailers}.map((retailer) {
                  final id = retailer['id'].toString();
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(
                      retailer['retailer']?['name'] ?? 'N/A',
                      style: const TextStyle(fontFamily: "poppins"),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          if (retailerProvider.isLoading && retailerProvider.retailers.isEmpty)
            Positioned(
              right: 30,
              top: 0,
              bottom: 0,
              child: Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.mainAppColor,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(StateSetter setState) {
    final statuses = [
      {'label': 'PENDING', 'value': 'pending'},
      {'label': 'DELIVERED', 'value': 'delivered'},
      {'label': 'SELF-PICKED', 'value': 'self-picked'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final bool isSelected = selectedStatus == status['value'];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedStatus = isSelected ? null : status['value'] as String;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.mainAppColor : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.mainAppColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status['label'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.mainAppColor,
                fontFamily: "poppins",
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  void _showFilterDialog(BuildContext context) {
    final retailerProvider = Provider.of<RetailerForFilterProvider>(context, listen: false);
    retailerProvider.resetState();

    // Fetch initial retailers
    retailerProvider.fetchRetailers(
      refresh: true,
      context: context,
    ).then((_) {
      // Load all remaining retailers
      retailerProvider.loadAllRetailers(context);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
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
                        fontFamily: "poppins",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedRetailerId = null;
                          selectedStatus = null;
                          selectedModeOfDelivery = null;
                        });
                        context.read<WholeSellerOrderProvider>().resetFilters(context);
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.mainAppColor,
                          fontFamily: "poppins",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Filter Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Retailer Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins",
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<RetailerForFilterProvider>(
                        builder: (context, retailerProvider, _) =>
                            _buildRetailerDropdown(retailerProvider, setState),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins",
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusSelector(setState),
                      const SizedBox(height: 20),
                      const Text(
                        'Mode of Delivery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins",
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDeliveryModeSelector(setState),
                    ],
                  ),
                ),
              ),
              // Apply Button
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
                          context.read<WholeSellerOrderProvider>().applyFilters(
                            retailerId: selectedRetailerId,
                            status: selectedStatus,
                            modeOfDelivery: selectedModeOfDelivery,
                            context: context,
                          );
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
                            fontFamily: "poppins",
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
      ),
    );
  }
  Widget _buildDeliveryModeSelector(StateSetter setState) {
    final deliveryModes = [
      {'label': 'DELIVERY', 'value': 'delivery'},
      {'label': 'SELF-PICK', 'value': 'self_pick'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: deliveryModes.map((mode) {
        final bool isSelected = selectedModeOfDelivery == mode['value'];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedModeOfDelivery = isSelected ? null : mode['value'] as String;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.mainAppColor : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.mainAppColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              mode['label'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.mainAppColor,
                fontFamily: "poppins",
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  Widget _buildOrderList() {
    return Expanded(
      child: Consumer<WholeSellerOrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: AppColors.mainAppColor,
                size: 40,
              ),
            );
          }

          if (provider.orders.isEmpty) {
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "poppins",
                  color: Colors.grey,
                ),
              ),
            );
          }

          if (_isSearching && provider.orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10),
              itemCount: provider.orders.length + (provider.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.orders.length) {
                  return provider.isLoading
                      ? Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColors.mainAppColor,
                      size: 40,
                    ),
                  )
                      : const SizedBox.shrink();
                }
                return _buildOrderCard(provider.orders[index]);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }
}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}