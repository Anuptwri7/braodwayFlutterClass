// import 'dart:developer';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../const/styleConst.dart';
// import '../model/addressModel.dart';
// import '../provider/address_provider.dart';
// import '../provider/getAddressProvider.dart';
// import '../provider/order_provider.dart';
//
// class CheckoutPage extends StatefulWidget {
//   final List<dynamic> cartItemsData;
//
//   const CheckoutPage({super.key, required this.cartItemsData});
//
//   @override
//   State<CheckoutPage> createState() => _CheckoutPageState();
// }
//
// class _CheckoutPageState extends State<CheckoutPage> {
//   String _paymentMethod = 'COD';
//   final _formKey = GlobalKey<FormState>();
//   String _selectedAddressId = '';
//   bool _isExpanded = false; // Track the expansion state
//
//   // Controllers for text fields
//   TextEditingController nameController = TextEditingController();
//   TextEditingController mobileController = TextEditingController();
//   TextEditingController streetController = TextEditingController();
//   TextEditingController cityController = TextEditingController();
//   TextEditingController stateController = TextEditingController();
//   TextEditingController pinCodeController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<AddressProviderGet>(context, listen: false).fetchAddress();
//     });
//     log(widget.cartItemsData.toString());
//   }
//
//   @override
//   void dispose() {
//     // Dispose the controllers to free resources
//     nameController.dispose();
//     mobileController.dispose();
//     streetController.dispose();
//     cityController.dispose();
//     stateController.dispose();
//     pinCodeController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final addressProvider = Provider.of<AddressProviderGet>(context);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           "Checkout",
//           style: TextStyle(fontFamily: "poppins",color: Colors.black, fontWeight: FontWeight.w500),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         // Make the body scrollable
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 30.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.location_on_rounded),
//                     SizedBox(width: 5),
//                     Text("Shipping Address",
//                         style: TextStyle(fontFamily: "poppins",
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black)),
//                   ],
//                 ),
//                 FutureBuilder(
//                   builder: (context, snapshot) {
//                     if (addressProvider.addressListing == null) {
//                       return Center(child: LoadingAnimationWidget.threeArchedCircle(
//                 color: AppColors.mainAppColor,
//                 size: 40,
//               ),);
//                     } else if (addressProvider.addressListing!.data!.isEmpty) {
//                       return Center(child: Text('No addresses available.'));
//                     } else {
//                       return Container(
//                         height: 450,
//                         width: MediaQuery.of(context).size.width,
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: ListView.builder(
//                           padding: const EdgeInsets.all(8.0),
//                           itemCount: addressProvider.addressListing!.data!.length,
//                           itemBuilder: (context, index) {
//                             Data addressData = addressProvider.addressListing!.data![index];
//
//                             return Card(
//                               elevation: 3,
//                               shadowColor: Colors.grey.withOpacity(0.5),
//                               margin: const EdgeInsets.symmetric(vertical: 8.0),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             addressData.name ?? 'Name',
//                                             style: ralewayStyle.copyWith(
//                                               fontWeight: FontWeight.w600,
//                                               color: AppColors.mainAppColor,
//                                               fontSize: 16.0,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.phone, color: Colors.grey),
//                                         const SizedBox(width: 8.0),
//                                         Expanded(
//                                           child: Text(
//                                             addressData.mobile ?? 'Mobile Number',
//                                             style: ralewayStyle.copyWith(
//                                               fontWeight: FontWeight.w400,
//                                               fontSize: 14.0,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.location_city, color: Colors.grey),
//                                         const SizedBox(width: 8.0),
//                                         Expanded(
//                                           child: Text(
//                                             addressData.city ?? 'City',
//                                             style: ralewayStyle.copyWith(
//                                               fontWeight: FontWeight.w400,
//                                               fontSize: 14.0,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.home, color: Colors.grey),
//                                         const SizedBox(width: 8.0),
//                                         Expanded(
//                                           child: Text(
//                                             addressData.street ?? 'Street Address',
//                                             style: ralewayStyle.copyWith(
//                                               fontWeight: FontWeight.w400,
//                                               fontSize: 14.0,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Row(
//                                             children: [
//                                               Icon(Icons.map, color: Colors.grey),
//                                               const SizedBox(width: 8.0),
//                                               Expanded(
//                                                 child: Text(
//                                                   addressData.state ?? 'State',
//                                                   style: ralewayStyle.copyWith(
//                                                     fontWeight: FontWeight.w400,
//                                                     fontSize: 14.0,
//                                                     color: Colors.black87,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     }
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 // Expandable panel for contact details
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         _isExpanded ? Icons.remove : Icons.add,
//                         color: Colors.black,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isExpanded = !_isExpanded; // Toggle expansion state
//                         });
//                       },
//                     ),
//                     Text(
//                       "Contact Details",
//                       style: TextStyle(fontFamily: "poppins",
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (_isExpanded) // Show the contact details if expanded
//                   Column(
//                     children: [
//                       SizedBox(height: 10),
//                       TextFormField(
//                         controller: nameController,
//                         decoration: InputDecoration(
//                           labelText: "Full Name",
//                           hintText: "Enter your Full Name",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter your full name';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 10),
//                       TextFormField(
//                         controller: mobileController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           labelText: "Mobile Number",
//                           hintText: "Enter your Mobile Number",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter your mobile number';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: streetController,
//                         decoration: InputDecoration(
//                           labelText: "Street Address",
//                           hintText: "Enter your Street Address",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter your street address';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         controller: cityController,
//                         decoration: InputDecoration(
//                           labelText: "City",
//                           hintText: "Enter your City",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter your city';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         controller: stateController,
//                         decoration: InputDecoration(
//                           labelText: "State",
//                           hintText: "Enter your State",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter your state';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         controller: pinCodeController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           labelText: "Pin Code",
//                           hintText: "Enter your Pin Code",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter your pin code';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 16.0),
//                         child: Align(
//                           alignment: Alignment.centerRight,
//                           child: SizedBox(
//                             width: MediaQuery.of(context).size.width/4,
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 if (_formKey.currentState!.validate()) {
//                                   // Save address using AddressProvider
//                                   final addressProvider = Provider.of<AddressProvider>(
//                                       context,
//                                       listen: false);
//                                   try {
//                                     await addressProvider.saveAddress(
//                                       name: nameController.text,
//                                       mobile: mobileController.text,
//                                       street: streetController.text,
//                                       city: cityController.text,
//                                       state: stateController.text,
//                                       pinCode: pinCodeController.text.isEmpty
//                                           ? null
//                                           : pinCodeController.text,
//                                     );
//                                   } catch (error) {
//                                     log('Error saving address: $error');
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                           content: Text(
//                                               'Failed to save address. Please try again.')),
//                                     );
//                                   }
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 padding:
//                                 EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 backgroundColor: AppColors.mainAppColor,
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'Save',
//                                   style: TextStyle(fontFamily: "poppins",color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 SizedBox(height: 30),
//                 // Add the "Pay Now" button
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       _submitOrder(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding:
//                       EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       backgroundColor: AppColors.mainAppColor,
//                     ),
//                     child: Center(
//                       child: Text(
//                         'Place Order',
//                         style: TextStyle(fontFamily: "poppins",color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   void _submitOrder(BuildContext context) async {
//     try {
//       final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//       await orderProvider.placeOrder(
//         cartItems: widget.cartItemsData,
//         shippingAddressId: _selectedAddressId,
//       );
//       Navigator.pop(context);
//     } catch (error) {
//       log(error.toString());
//     }
//   }
// }
