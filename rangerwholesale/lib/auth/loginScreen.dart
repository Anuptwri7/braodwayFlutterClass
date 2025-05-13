import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/auth/sign_up.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import '../provider/login_provider.dart';
import 'send_email.dart';
// import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  bool obsecureTextState = true;
  var username, password;
  var checkedValue = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  IconData showPasswordIcon = Icons.remove_red_eye;
  // final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  // List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // _checkBiometrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      if (loginProvider.rememberedEmail != null) {
        setState(() {
          _emailController.text = loginProvider.rememberedEmail!;
          username = loginProvider.rememberedEmail!;
          checkedValue = true;
        });
      }
    });
  }
  // Future<void> _checkBiometrics() async {
  //   try {
  //     _canCheckBiometrics = await auth.canCheckBiometrics;
  //     _availableBiometrics = await auth.getAvailableBiometrics();
  //   } on PlatformException catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   setState(() {});
  // }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loginProvider = Provider.of<LoginProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.mainAppColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return false;
              },
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 90, right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                AppText.loginMainText,
                                style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                AppText.loginSubText,
                                style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              kHeightSmall,
                              Text(
                                AppText.loginAdditionalText,
                                style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22.0,
                                vertical: 50.0,
                              ),
                              child: Form(
                                key: _loginFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(child: Image.asset(AppIcons.appIcon)),
                                    const SizedBox(height: 60),
                                    TextFormField(
                                      controller: _emailController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        final emailRegex = RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                        );
                                        if (!emailRegex.hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                      cursorColor: AppColors.mainAppColor,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (value) {
                                        username = value;
                                      },
                                      style: const TextStyle(
                                        fontFamily: "poppins",
                                        color: Colors.black,
                                      ),
                                      decoration: kFormFieldDecoration.copyWith(
                                        hintText: 'Email',
                                      ),
                                    ),
                                    kHeightVeryBig,
                                    TextFormField(
                                      controller: _passwordController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Your Password';
                                        }
                                        return null;
                                      },
                                      style: const TextStyle(
                                        fontFamily: "poppins",
                                        color: Colors.black,
                                      ),
                                      obscureText: obsecureTextState,
                                      cursorColor: AppColors.mainAppColor,
                                      onChanged: (value) {
                                        password = value;
                                      },
                                      decoration: kFormFieldDecoration.copyWith(
                                        hintText: "Password",
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obsecureTextState = !obsecureTextState;
                                              showPasswordIcon = obsecureTextState
                                                  ? Icons.remove_red_eye
                                                  : Icons.remove_red_eye_outlined;
                                            });
                                          },
                                          icon: Icon(
                                            showPasswordIcon,
                                            color: AppColors.mainAppColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: checkedValue,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  checkedValue = newValue!;
                                                });
                                              },
                                              activeColor: AppColors.mainAppColor,
                                              checkColor: Colors.white,
                                            ),
                                            const Text(
                                              'Remember me',
                                              style: TextStyle(
                                                fontFamily: "poppins",
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const SentEmail(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              fontFamily: "poppins",
                                              fontSize: 14,
                                              color: AppColors.mainAppColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: loginProvider.isLoading
                                            ? null
                                            : () {
                                          if (_loginFormKey.currentState!.validate()) {
                                            loginProvider.login(
                                              username!,
                                              password!,
                                              checkedValue,
                                              context,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: AppColors.mainAppColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                        ),
                                        child: loginProvider.isLoading
                                            ? LoadingAnimationWidget.hexagonDots(
                                          color: Colors.white,
                                          size: 24,
                                        )
                                            : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontFamily: "poppins",
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // if (_canCheckBiometrics && _availableBiometrics.isNotEmpty)
                                    //   Padding(
                                    //     padding: const EdgeInsets.only(top: 10.0),
                                    //     child: Center(
                                    //       child: IconButton(
                                    //         icon: const Icon(Icons.fingerprint, size: 36, color: AppColors.mainAppColor),
                                    //         onPressed: _authenticateWithBiometrics,
                                    //         tooltip: "Login with biometrics",
                                    //       ),
                                    //     ),
                                    //   ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Don\'t have an account? ',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) =>
                                                const RetailerRegistrationPage(),
                                                transitionsBuilder:
                                                    (context, animation, secondaryAnimation, child) {
                                                  var begin = const Offset(1.0, 0.0);
                                                  var end = Offset.zero;
                                                  var curve = Curves.easeInOutQuart;
                                                  var tween = Tween(begin: begin, end: end)
                                                      .chain(CurveTween(curve: curve));
                                                  return SlideTransition(
                                                    position: animation.drive(tween),
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              color: AppColors.mainAppColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  // Future<void> _authenticateWithBiometrics() async {
  //   try {
  //     bool didAuthenticate = await auth.authenticate(
  //       localizedReason: 'Please authenticate to login',
  //       options: const AuthenticationOptions(
  //         biometricOnly: true,
  //         stickyAuth: true,
  //       ),
  //     );
  //
  //     if (didAuthenticate) {
  //
  //       if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
  //         final loginProvider = Provider.of<LoginProvider>(context, listen: false);
  //         loginProvider.login(
  //           _emailController.text,
  //           _passwordController.text,
  //           checkedValue,
  //           context,
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Email/Password not available")),
  //         );
  //       }
  //     }
  //   } on PlatformException catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

}
