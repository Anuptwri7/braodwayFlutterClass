import 'package:flutter/material.dart';
import 'package:rangerwholesale/const/styleConst.dart';

class WholeSellerOrderDetail extends StatefulWidget {
  final Map<String, dynamic> order;

  const WholeSellerOrderDetail({Key? key, required this.order})
      : super(key: key);

  @override
  State<WholeSellerOrderDetail> createState() => _WholeSellerOrderDetailState();
}

class _WholeSellerOrderDetailState extends State<WholeSellerOrderDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${widget.order['uniqueCode'] ?? 'N/A'}',
                style: const TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
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
                      _buildDeliveryModeSection(),
                      const SizedBox(height: 20),
                      _buildSectionHeader("Product Details"),
                      const SizedBox(height: 10),
                      _buildProductList(),

                      // Total Price
                      _buildTotalPriceWidget(),

                      // Shipping Address Section
                      const SizedBox(height: 20),
                      widget.order['modeOfDelivery'] == "delivery"
                          ? _buildSectionHeader("Shipping Address")
                          : Container(),
                      const SizedBox(height: 10),
                      widget.order['modeOfDelivery'] == "delivery"
                          ? _buildShippingAddressDetails()
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
          widget.order['modeOfDelivery'] == "delivery"
              ? const Icon(Icons.local_shipping, color: AppColors.mainAppColor)
              : const Icon(Icons.store, color: AppColors.mainAppColor),
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
                  (widget.order['modeOfDelivery']?.toString() ??
                          'Standard Delivery')
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
        const Divider(
          color: Colors.black12,
          thickness: 2,
        ),
      ],
    );
  }

  Widget _buildProductList() {
    // Assuming cartItems is a list of maps in the order
    List<dynamic> cartItems = widget.order['cartItem'] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        var product = cartItems[index];
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
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product['productVariant']['product']
                              ['shopifyImageUrl'] !=
                          null
                      ? Image.network(
                          product['productVariant']['product']
                              ['shopifyImageUrl'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.mainAppColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image,
                                color: Colors.grey[600]),
                          ),
                        )
                      : Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, color: Colors.grey[600]),
                        ),
                ),
                const SizedBox(width: 15),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['productVariant']['product']['name'] ?? "N/A",
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
                            '\$${product['productVariant']['price'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              color: AppColors.mainAppColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Qty: ${product['quantity'] ?? 'N/A'}',
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalPriceWidget() {
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
              "\$${double.tryParse(widget.order['price']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
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
    // Assuming shippingAddress is a map within the order
    Map<String, dynamic> shippingAddress =
        widget.order['shippingAddress'] ?? {};

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
          _buildAddressRow("Name", shippingAddress['name'] ?? 'N/A'),
          _buildAddressRow("Mobile", shippingAddress['mobile'] ?? 'N/A'),
          _buildAddressRow("State", shippingAddress['state'] ?? 'N/A'),
          _buildAddressRow("City",
              (shippingAddress['city'] as String?)?.toUpperCase() ?? 'N/A'),
          _buildAddressRow("Street", shippingAddress['street'] ?? 'N/A'),
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
}
