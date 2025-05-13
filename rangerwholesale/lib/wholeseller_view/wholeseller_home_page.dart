import 'package:flutter/material.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/wholeseller_view/retailer_page.dart';
import 'package:rangerwholesale/wholeseller_view/wholeseller_dashboard.dart';
import 'package:rangerwholesale/wholeseller_view/wholeseller_order_page.dart';
import 'package:rangerwholesale/wholeseller_view/wholeseller_product_page.dart';
import 'package:rangerwholesale/wholeseller_view/wholeseller_profile_page.dart';

class WholeSellerHomePage extends StatefulWidget {
  const WholeSellerHomePage({super.key});

  @override
  _WholeSellerHomePageState createState() => _WholeSellerHomePageState();
}

class _WholeSellerHomePageState extends State<WholeSellerHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WholeSellerDashboard(),
    const WholeSellerProductPage(),
    const WholeSellerOrderPage(show: false),
    const RetailerListingPage(),
    const WholeSellerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await _showExitDialog(context);
        return shouldExit;
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min, // Ensures the column doesn't expand unnecessarily
          children: [
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed, // Prevent icon sliding animation
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: AppColors.mainAppColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              backgroundColor: Colors.white, // Background for the BottomNavigationBar
              elevation: 0, // Remove default shadow for clean design
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: "Products",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: "Orders",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: "Retailers",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_pin),
                  label: "Profile",
                ),
              ],
            ),
          ],
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
      barrierColor: Colors.black54,  // Slightly darker overlay
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
    ) ?? false;
  }
}