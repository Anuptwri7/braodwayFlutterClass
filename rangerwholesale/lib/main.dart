import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/homePage.dart';
import 'package:rangerwholesale/provider/edit_profile_provider.dart';
import 'package:rangerwholesale/provider/retailerForFilter.dart';
import 'package:rangerwholesale/provider/retailer_profile_provider.dart';
import 'package:rangerwholesale/provider/signup_provider.dart';
import 'package:rangerwholesale/wholeseller_view/provider/retailer_provider.dart';
// Import Screens
import 'package:rangerwholesale/auth/loginScreen.dart';
// Import Providers
import 'package:rangerwholesale/const/stringConst.dart';
import 'package:rangerwholesale/provider/address_provider.dart';
import 'package:rangerwholesale/provider/cart_provider.dart';
import 'package:rangerwholesale/provider/category_provider.dart';
import 'package:rangerwholesale/provider/change_password_provider.dart';
import 'package:rangerwholesale/provider/featured_product_provider.dart';
import 'package:rangerwholesale/provider/getAddressProvider.dart';
import 'package:rangerwholesale/provider/login_provider.dart';
import 'package:rangerwholesale/provider/order_provider.dart';
import 'package:rangerwholesale/provider/otp_provider.dart';
import 'package:rangerwholesale/provider/product_provider.dart';
import 'package:rangerwholesale/provider/profile_provider.dart';
import 'package:rangerwholesale/provider/scan_provider.dart';
import 'package:rangerwholesale/provider/subcategory_provider.dart';
import 'package:rangerwholesale/wholeseller_view/provider/admin_product_provider.dart';
import 'package:rangerwholesale/wholeseller_view/provider/dashboard_provider.dart';
import 'package:rangerwholesale/wholeseller_view/provider/wholeseller_order_provider.dart';
import 'package:rangerwholesale/wholeseller_view/wholeseller_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // General Providers
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChangePasswordProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        // Product and Category Providers
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryListingProvider()),
        ChangeNotifierProvider(create: (_) => SubcategoryProvider()),
        ChangeNotifierProvider(create: (_) => FeaturedProductProvider()),
        // Cart and Order Providers
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        // Address and Scan Providers
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => AddressProviderGet()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        // Wholeseller and Dashboard Providers
        ChangeNotifierProvider(create: (_) => AdminProductProvider()),
        ChangeNotifierProvider(create: (_) => DashboardDataProvider()),
        ChangeNotifierProvider(create: (_) => WholeSellerOrderProvider()),
        ChangeNotifierProvider(create: (_) => RetailerProvider()),
        ChangeNotifierProvider(create: (_) => RetailerForFilterProvider()),
        ChangeNotifierProvider(create: (_) => EditRetailerProvider()),
        ChangeNotifierProvider(create: (_) => RetailerProfileProvider()),

      ],
      child: const MyApp(),
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${StringConst.appNameFirst}${StringConst.appNameSecond}',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xffE62526, {
          50: Color(0xffE62526),
          100: Color(0xffE62526),
          200: Color(0xffE62526),
          300: Color(0xffE62526),
          400: Color(0xffE62526),
          500: Color(0xffE62526),
          600: Color(0xffE62526),
          700: Color(0xffE62526),
          800: Color(0xffE62526),
          900: Color(0xffE62526),
        }),
        brightness: Brightness.light,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }
//
//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString("access_token");
//     final userRole = prefs.getString("userType") ?? "";
//
//     // Simulate splash screen delay
//     await Future.delayed(const Duration(seconds: 2));
//
//     if (accessToken != null && accessToken.isNotEmpty) {
//       if (userRole == "whole_seller") {
//         _navigateTo(const WholeSellerHomePage());
//       } else if (userRole == "retailer") {
//         _navigateTo(const Homepage());
//       } else {
//         _navigateTo(const LoginScreen());
//       }
//     } else {
//       _navigateTo(const LoginScreen());
//     }
//   }
//
//   void _navigateTo(Widget page) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => page),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green.shade50, // Light green background
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // App Icon
//             Image.asset(
//               'assets/icons/appIcon.png',
//               width: 150,
//               height: 150,
//             ),
//             const SizedBox(height: 20),
//
//             // // App Name Text
//             // Text(
//             //   "Ranger Wholesale",
//             //   style: TextStyle(
//             //     fontSize: 24,
//             //     fontWeight: FontWeight.bold,
//             //     color: AppColors.mainAppColor,
//             //   ),
//             // ),
//             // const SizedBox(height: 10),
//             //
//             // // Subtitle Text
//             // const Text(
//             //   "Your One-Stop Shop!",
//             //   style: TextStyle(
//             //     fontSize: 16,
//             //     color: Colors.black54,
//             //   ),
//             // ),
//             // const SizedBox(height: 50),
//
//             // Loading Indicator
//             LoadingAnimationWidget.prograssiveDots(
//               color: AppColors.mainAppColor,
//               size: 40,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");
    final userRole = prefs.getString("userType") ?? "";
    final rememberedEmail = prefs.getString('remembered_email');
    final savedPassword = prefs.getString('saved_password');

    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 2));

    if (accessToken != null && accessToken.isNotEmpty) {
      // Valid session exists, navigate based on user role
      if (userRole == "whole_seller") {
        _navigateTo(const WholeSellerHomePage());
      } else {
        _navigateTo(const Homepage());
      }
    } else if (rememberedEmail != null && savedPassword != null) {
      // Attempt auto-login with saved credentials
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      try {
        await loginProvider.login(rememberedEmail, savedPassword, true, context);
      } catch (e) {
        _navigateTo(const LoginScreen());
      }
    } else {
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Image.asset(
              'assets/icons/appIcon.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),

            // Loading Indicator
            LoadingAnimationWidget.prograssiveDots(
              color: AppColors.mainAppColor,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
