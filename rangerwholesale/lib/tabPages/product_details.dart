import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/provider/cart_provider.dart';

import '../model/product_listing_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductList product;

  const ProductDetailsPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final TextEditingController _quantityController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateQuantity(int delta) {
    // Store current cursor position
    final currentPosition = _quantityController.selection.baseOffset;

    // Get current quantity
    final currentQuantity = int.tryParse(_quantityController.text) ?? 1;
    final newQuantity = (currentQuantity + delta).clamp(1, 99999);

    // Update text
    _quantityController.text = newQuantity.toString();

    // Restore cursor position if it was in a valid range
    if (currentPosition >= 0 && currentPosition <= _quantityController.text.length) {
      _quantityController.selection = TextSelection.fromPosition(
          TextPosition(offset: currentPosition.clamp(0, _quantityController.text.length))
      );
    } else {
      // If no valid cursor position, put cursor at the end
      _quantityController.selection = TextSelection.fromPosition(
          TextPosition(offset: _quantityController.text.length)
      );
    }
  }

  void _addToCart(BuildContext context) {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (widget.product.id != null) {
      context.read<CartProvider>().addToCart(
        context,
        widget.product.id!,
        quantity: quantity,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                const SizedBox(height: 20),
                _buildProductInfo(),
                const SizedBox(height: 20),
                _buildQuantitySelector(),
                const SizedBox(height: 20),
                _buildAddToCartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Product Details",
        style: TextStyle(
          fontFamily: "Poppins",
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        color: Colors.black,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: widget.product.image != null
              ? Image.network(
            widget.product.image!,
            fit: BoxFit.contain,
            height: MediaQuery.of(context).size.height * 0.3,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.mainAppColor,
                  size: 40,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error_outline,
                size: 70,
                color: Colors.grey,
              );
            },
          )
              : const Icon(Icons.image, size: 70, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name ?? "Product Name",
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
                (index) => Icon(
              index < (4)
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "\$${widget.product ?? 'N/A'}",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.product.name ?? "No description available.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Quantity",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          width: 120,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            border: Border.all(
              color: AppColors.mainAppColor,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuantityButton(
                onTap: () => _updateQuantity(-1),
                icon: '-',
              ),
              SizedBox(
                width: 40,
                child: TextField(
                  controller: _quantityController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty || newValue.text == '0') {
                        return oldValue;
                      }
                      final number = int.tryParse(newValue.text);
                      if (number == null || number < 1) {
                        return oldValue;
                      }
                      if (number > 99999) {
                        return oldValue;
                      }
                      return newValue;
                    }),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty || value == '0') {
                      _quantityController.text = '1';
                      _quantityController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _quantityController.text.length),
                      );
                    }
                  },
                ),
              ),
              _buildQuantityButton(
                onTap: () => _updateQuantity(1),
                icon: '+',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required VoidCallback onTap,
    required String icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Text(
          icon,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            color: AppColors.mainAppColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _addToCart(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.mainAppColor,
          elevation: 5,
        ),
        child: const Text(
          "Add to Cart",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}