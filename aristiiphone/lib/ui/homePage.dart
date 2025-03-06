// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
//
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:otp/otp.dart';
// // import 'package:otp/otp.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:untitled/const/styleConst.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   LatLng? currentLocation;
//   String? totp;
//   late Timer timer;
//   late DateTime currentTime;
//   bool isScanned = false;
//   String secretKey = '';
//   String appName = '';
//
//   Future<void> _getCurrentLocation() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//
//     LocationPermission locationPermission = await Geolocator.checkPermission();
//     if (locationPermission == LocationPermission.denied) {
//       locationPermission = await Geolocator.requestPermission();
//       if (locationPermission == LocationPermission.deniedForever) {
//
//       }
//     }
//
//     if (locationPermission == LocationPermission.whileInUse ||
//         locationPermission == LocationPermission.always) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.bestForNavigation,
//         );
//         double fenceLat = position.latitude;
//         double fenceLng = position.longitude;
//         log("lat${position.latitude}");
//         log("lang${position.longitude}");
//
//         double distanceInMeters = Geolocator.distanceBetween(
//           position.latitude,
//           position.longitude,
//           fenceLat,
//           fenceLng,
//         );
//
//         if (distanceInMeters <= 25) {
//           setState(() {
//             currentLocation = LatLng(position.latitude, position.longitude);
//             preferences.setDouble("lat", position.latitude);
//             preferences.setDouble("lng", position.longitude);
//           });
//         } else {
//           // Handle location outside the fence
//         }
//       } catch (e) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Location Service Disabled'),
//             content: const Text('Please enable location services to use this app.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context); // Close the dialog
//                   Navigator.pop(context); // Close the screen
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Location Permission Required'),
//           content: const Text('This app requires access to your location to function properly.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Close the dialog
//                 Navigator.pop(context); // Close the screen
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//   @override
//   void initState() {
//     super.initState();
//     _getLocalData();
//     currentTime = DateTime.now();
//     _getCurrentLocation();
//
//     timer = Timer(Duration(seconds: 0), () {});
//   }
//   void _initializeState() {
//     _getLocalData();
//     currentTime = DateTime.now();
//     // Initialize the timer with a dummy callback
//     timer = Timer(Duration(seconds: 0), () {});
//   }
//   Future<void> _getLocalData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     secretKey = prefs.getString('secretKey') ?? '';
//     appName = prefs.getString('appName') ?? 'Aristi Authenticator';
//     if (secretKey.isNotEmpty) {
//       String code = OTP.generateTOTPCodeString(secretKey, DateTime.now().millisecondsSinceEpoch, isGoogle: true, algorithm: Algorithm.SHA1);
//       log(secretKey.toString());
//       startTimer();
//     }
//   }
//
//   String _scanBarcode = 'Unknown';
//
//   String _generateTOTP() {
//     if (secretKey.isNotEmpty) {
//       String totpValue = OTP.generateTOTPCodeString(secretKey, DateTime.now().millisecondsSinceEpoch, isGoogle: true, algorithm: Algorithm.SHA1);
//       return totpValue;
//     } else {
//       return '';
//     }
//   }
//
//   void startTimer() {
//     timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
//       setState(() {
//         currentTime = DateTime.now();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(appName),
//         backgroundColor: appBarColor,
//         actions: [
//           IconButton(
//             icon: Icon(FontAwesomeIcons.deleteLeft),
//             onPressed: () async{
//               SharedPreferences prefs =await SharedPreferences.getInstance();
//               setState(() {
//                 prefs.clear();
//                 _initializeState();
//                 isScanned=false;
//               });
//
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset('assets/logo.png', height: 200),
//               SizedBox(height: 20),
//               Text(
//                 'Secure Your Aristi Account',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black54,
//                 ),
//               ),
//               SizedBox(height: 10),
//               (isScanned || secretKey.isNotEmpty)
//                   ? _buildAuthenticatorView()
//                   : ElevatedButton(
//                 onPressed: () async {
//                   await scanQR();
//                 },
//                 child: Text("Scan QR"),
//                 style: ButtonStyle(
//                   backgroundColor:
//                   MaterialStateProperty.all<Color>(appBarColor),
//                 ),
//               ),
//               SizedBox(height: 20),
//               AnimatedSwitcher(
//                 duration: Duration(milliseconds: 500),
//                 transitionBuilder: (child, animation) {
//                   return FadeTransition(
//                     opacity: animation,
//                     child: child,
//                   );
//                 },
//                 child: Text(
//                   _generateTOTP(),
//                   key: ValueKey<String>(_generateTOTP()),
//                   style: TextStyle(
//                     fontSize: 48,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Visibility(
//                 visible: secretKey.isNotEmpty,
//                 child: Text(
//                   'Next refresh in: ${(30 - currentTime.second % 30)} seconds',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> scanQR() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String barcodeScanRes;
//     try {
//       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//         '#ff6666',
//         'Cancel',
//         true,
//         ScanMode.QR,
//       );
//       Uri uri = Uri.parse(barcodeScanRes);
//       String scannedSecretKey = uri.queryParameters['secret'] ?? '';
//        appName = uri.queryParameters['issuer'] ?? '';
//       preferences.setString("secretKey", scannedSecretKey);
//       preferences.setString("appName", appName);
//       log("result" + barcodeScanRes);
//     } on PlatformException {
//       barcodeScanRes = 'Failed to get platform version.';
//     }
//
//     if (!mounted) return;
//
//     setState(() {
//       _scanBarcode = barcodeScanRes;
//       if (_scanBarcode != '-1') {
//         isScanned = true;
//         secretKey = preferences.getString("secretKey") ?? ''; // Update secretKey from preferences
//         totp = OTP.generateTOTPCodeString(secretKey, DateTime.now().millisecondsSinceEpoch, isGoogle: true, algorithm: Algorithm.SHA1);
//         startTimer();
//       }
//     });
//   }
//
//   Widget _buildAuthenticatorView() {
//     return Column(
//       children: [
//         Text(
//           'Authenticated!',
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.green,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 10),
//         Icon(
//           FontAwesomeIcons.checkCircle,
//           size: 50,
//           color: Colors.green,
//         ),
//       ],
//     );
//   }
// }
