import 'dart:developer';
import 'dart:ui';
import 'package:badges/badges.dart' as badges;
// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/styleConst.dart';
import '../provider/cart_provider.dart';
import '../provider/scan_provider.dart';
import '../tabPages/cart.dart';
import '../tabPages/category_page.dart';
import '../tabPages/dashboard.dart';
import '../tabPages/profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCartData(context);
    });
  }

  Future<void> _startScanning() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: ScannerView(
            onBarcodeDetected: (String barcode) async {
              Navigator.pop(context);

              final scanProvider = Provider.of<ScanProvider>(context, listen: false);
              scanProvider.clearScanData();

              final success = await scanProvider.fetchScanData(barcode, context);

              if (success && scanProvider.scanData != null) {
                _showScanResult(scanProvider.scanData!);
              } else {
                print(scanProvider.scanData.toString());
                log(scanProvider.scanData.toString());
                Fluttertoast.showToast(
                  msg: "No products found for this QR code${scanProvider.scanData}${barcode}",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      const Dashboard(),
      const CategoryPage(),
      Container(),
      const CartPage(),
      const ProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _startScanning();
    } else {
      _pageController.jumpToPage(index);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showScanResult(Map<String, dynamic> data) {
    if (data['data'] == null ||
        data['data']['productVariants'] == null ||
        (data['data']['productVariants'] as List).isEmpty) {
      Fluttertoast.showToast(
        msg: "No product details available",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final TextEditingController quantityController = TextEditingController();
    final FocusNode quantityFocusNode = FocusNode();
    quantityController.text = "1";

    void updateQuantity(int change) {
      int currentValue = int.tryParse(quantityController.text) ?? 1;
      int newValue = (currentValue + change).clamp(1, 99999);
      quantityController.text = newValue.toString();
      quantityFocusNode.unfocus();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final productData = data['data'] ?? {};
            final variants = productData['productVariants'] as List?;
            final firstVariant =
            variants?.isNotEmpty == true ? variants!.first : null;
            final price = firstVariant?['price'] ?? '0';
            final imageUrl = productData['shopifyImageUrl'];
            final name = productData['name'] ?? 'Unnamed Product';
            final variantId = firstVariant?['id'];

            return Dialog(
              backgroundColor: Colors.transparent,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Product",
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: imageUrl != null && imageUrl != 'nan'
                            ? Image.network(
                          imageUrl,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width:
                              MediaQuery.of(context).size.width * 0.6,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  size: 60, color: Colors.grey),
                            );
                          },
                        )
                            : Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.6,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported,
                              size: 60, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Price: \$${(double.tryParse(price) ?? 0).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontFamily: "poppins",
                          fontSize: 14,
                          color: AppColors.mainAppColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mainAppColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  setState(() => updateQuantity(-1)),
                              color: AppColors.mainAppColor,
                              iconSize: 20,
                            ),
                            SizedBox(
                              width: 40,
                              child: TextField(
                                controller: quantityController,
                                focusNode: quantityFocusNode,
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
                                  if (value.isNotEmpty) {
                                    int? parsed = int.tryParse(value);
                                    if (parsed == null || parsed < 1) {
                                      quantityController.text = '1';
                                      quantityController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                                offset:
                                                quantityController.text.length),
                                          );
                                    }
                                  }
                                },
                                onEditingComplete: () {
                                  if (quantityController.text.isEmpty) {
                                    quantityController.text = '1';
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value.isEmpty ||
                                      int.tryParse(value) == null ||
                                      int.parse(value) < 1) {
                                    quantityController.text = '1';
                                  }
                                  updateQuantity(0);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  setState(() => updateQuantity(1)),
                              color: AppColors.mainAppColor,
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: variantId != null
                              ? () async{
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
                            final quantity =
                                int.tryParse(quantityController.text) ??
                                    1;
                            Provider.of<CartProvider>(context,
                                listen: false)
                                .addToCart(context, variantId,
                                quantity: quantity);
                            Navigator.of(context).pop();
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainAppColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Center(
                            child: Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontFamily: "poppins",
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await _showExitDialog(context);
        return shouldExit;
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(),
          children: _buildScreens(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.gpp_good_sharp),
              label: "Collections",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: "Scan",
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return cartProvider.cartItems.isNotEmpty
                      ? badges.Badge(
                    badgeContent: Text(
                      cartProvider.cartItems.length.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                    position:
                    badges.BadgePosition.topEnd(top: -5, end: -10),
                    child: const Icon(Icons.card_travel_outlined),
                  )
                      : const Icon(Icons.card_travel_outlined);
                },
              ),
              label: "Cart",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: "Profile",
            ),
          ],
          selectedItemColor: AppColors.mainAppColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    const Color backgroundColor = Colors.white;
    const Color textColor = Colors.black87;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54, // Slightly darker overlay
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Exit Icon in Circle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainAppColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColors.mainAppColor,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Exit App',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Message
                Text(
                  'Are you sure you want to exit the app?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Exit Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Exit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ??
        false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
class ScannerView extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const ScannerView({
    Key? key,
    required this.onBarcodeDetected,
  }) : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Scanner
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                if (_isProcessing) return;
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  setState(() => _isProcessing = true);
                  widget.onBarcodeDetected(barcodes.first.rawValue!);
                }
              },
            ),

            // Overlay
            Container(
              decoration: ShapeDecoration(
                shape: ScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 12,
                  borderLength: 32,
                  borderWidth: 3,
                  cutOutSize: 250,
                ),
              ),
            ),

            // Animated Scanner Line
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ScannerLinePainter(
                      progress: _animation.value,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // ValueListenableBuilder(
                    //   valueListenable: controller.torchState,
                    //   builder: (context, state, child) {
                    //     return IconButton(
                    //       icon: Icon(
                    //         state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                    //         color: Colors.white,
                    //       ),
                    //       onPressed: () => controller.toggleTorch(),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ),

            // Bottom Instructions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Align barcode within frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scanner will detect automatically',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }
}

// Custom Scanner Line Painter
class ScannerLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScannerLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0;

    final scanLineY = size.height * 0.3 + (size.height * 0.4 * progress);
    canvas.drawLine(
      Offset(size.width * 0.2, scanLineY),
      Offset(size.width * 0.8, scanLineY),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScannerLinePainter oldDelegate) => true;
}

// Custom Scanner Overlay Shape
class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color(0x80000000),
    this.borderRadius = 12.0,
    this.borderLength = 32.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutWidth = cutOutSize;
    final cutOutHeight = cutOutSize;
    final left = rect.left + (width - cutOutWidth) / 2;
    final top = rect.top + (height - cutOutHeight) / 3;
    final right = left + cutOutWidth;
    final bottom = top + cutOutHeight;

    final cutOutRect = Rect.fromLTRB(left, top, right, bottom);
    final backgroundPaint = Paint()..color = overlayColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(
        cutOutRect,
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(path, backgroundPaint);

    // Draw corners
    final borderOffset = borderWidth / 2;
    final cornerStart = borderLength;

    // Top left corner
    canvas.drawLine(
      Offset(left - borderOffset, top + cornerStart),
      Offset(left - borderOffset, top - borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left - borderOffset, top - borderOffset),
      Offset(left + cornerStart, top - borderOffset),
      borderPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(right - cornerStart, top - borderOffset),
      Offset(right + borderOffset, top - borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(right + borderOffset, top - borderOffset),
      Offset(right + borderOffset, top + cornerStart),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(right + borderOffset, bottom - cornerStart),
      Offset(right + borderOffset, bottom + borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(right + borderOffset, bottom + borderOffset),
      Offset(right - cornerStart, bottom + borderOffset),
      borderPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(left + cornerStart, bottom + borderOffset),
      Offset(left - borderOffset, bottom + borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left - borderOffset, bottom + borderOffset),
      Offset(left - borderOffset, bottom - cornerStart),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
    );
  }
}