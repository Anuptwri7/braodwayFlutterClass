import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../const/styleConst.dart';

class OrderDetails extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetails({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        order['uniqueCode']?.toString() ?? 'Order Details',
        style: const TextStyle(
          fontFamily: "Poppins",
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return false;
          },
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderStatusSection(),
                    const SizedBox(height: 20),
                    _buildSectionHeader("Product Details"),
                    const SizedBox(height: 10),
                    _buildProductList(),
                    _buildTotalPriceWidget(),
                    const SizedBox(height: 20),
                    _buildSectionHeader("Shipping Address"),
                    const SizedBox(height: 10),
                    _buildShippingAddressDetails(),
                    const SizedBox(height: 20),
                    if (order['modeOfDelivery'] != null)
                      _buildDeliveryModeSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.mainAppColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Order Status",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  _getStatusColor(order['status']?.toString()).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (order['status']?.toString() ?? 'Processing').toUpperCase(),
              style: TextStyle(
                fontFamily: "Poppins",
                color: _getStatusColor(order['status']?.toString()),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'self-picked':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.mainAppColor;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.mainAppColor,
          ),
        ),
        const Divider(color: Colors.black12, thickness: 2),
      ],
    );
  }

  Widget _buildProductList() {
    final List<dynamic> cartItems = order['cartItem'] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final product = cartItems[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product),
            const SizedBox(width: 15),
            Expanded(
              child: _buildProductDetails(product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(dynamic product) {
    final imageUrl = product['productVariant']?['product']?['shopifyImageUrl'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(true);
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(false),
            )
          : _buildImagePlaceholder(false),
    );
  }

  Widget _buildImagePlaceholder(bool isLoading) {
    return Container(
      height: 100,
      width: 100,
      color: Colors.grey[300],
      child: Center(
        child: isLoading
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.mainAppColor,
                  size: 40,
                ),
              )
            : Icon(Icons.image, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildProductDetails(dynamic product) {
    final productVariant = product['productVariant'];
    final productName = productVariant?['product']?['name'] ?? 'N/A';
    final price = productVariant?['price']?.toString() ?? '0.00';
    final quantity = product['quantity']?.toString() ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$$price',
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                color: AppColors.mainAppColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Qty: $quantity',
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalPriceWidget() {
    final price = order['price']?.toString() ?? '0.00';
    final formattedPrice = double.tryParse(price)?.toStringAsFixed(2) ?? '0.00';

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.mainAppColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Total: ",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Text(
              "\$$formattedPrice",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.mainAppColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressDetails() {
    final address = order['shippingAddress'] as Map<String, dynamic>?;
    if (address == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAddressRow("Name", address['name']?.toString() ?? 'N/A'),
          _buildAddressRow("Mobile", address['mobile']?.toString() ?? 'N/A'),
          _buildAddressRow("State", address['state']?.toString() ?? 'N/A'),
          _buildAddressRow(
              "City", (address['city']?.toString() ?? 'N/A').toUpperCase()),
          _buildAddressRow("Street", address['street']?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              color: AppColors.mainAppColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryModeSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: AppColors.mainAppColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery Mode",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  (order['modeOfDelivery']?.toString() ?? 'Standard Delivery')
                      .toUpperCase(),
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
