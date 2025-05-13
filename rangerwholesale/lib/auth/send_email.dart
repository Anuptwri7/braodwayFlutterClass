import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/auth/otp_page.dart';
import 'package:rangerwholesale/provider/otp_provider.dart';
import '../const/styleConst.dart';

class SentEmail extends StatefulWidget {
  const SentEmail({super.key});

  @override
  State<SentEmail> createState() => _SentEmailState();
}

class _SentEmailState extends State<SentEmail> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Email validation function
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Regular expression for validating an email address
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final otpProvider = Provider.of<OtpProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Reset Password",
            style: TextStyle(
                fontFamily: "poppins",
                color: Colors.black,
                fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: validateEmail, // Email validation
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: otpProvider.isLoading
                  ? null // Disable button while loading
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final success = await otpProvider.forgetPassword(
                          email: _emailController.text.trim(),
                        );
                        if (success) {
                          showSentEmailDialog(context); // Show success dialog
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor:
                    AppColors.mainAppColor, // Change color if needed
              ),
              child: otpProvider.isLoading
                  ? Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color:AppColors.mainAppColor,
                        size: 30,
                      ),
                    )
                  : const Text(
                      "Reset",
                      style: TextStyle(
                        fontFamily: "poppins",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void showSentEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog is dismissible
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          // Apply blur to the background
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
            ),
            title: Column(
              children: const [
                Icon(
                  Icons.lock_outline,
                  color: AppColors.mainAppColor,
                  size: 40, // Icon size
                ),
                SizedBox(height: 10),
                Text(
                  'OTP Sent \nSuccessfully',
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontWeight: FontWeight.bold, // Bold text
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              'OTP has been sent to your email',
              style: TextStyle(fontFamily: "poppins", fontSize: 16),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OtpPage(
                                email: _emailController.text.toString())));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    // Customize the button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'OK',
                      style:
                          TextStyle(fontFamily: "poppins", color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
