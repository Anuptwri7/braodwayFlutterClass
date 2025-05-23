import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscure = true;

  void signUpValidation() {
    if (firstNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter Your first name");
    } else if (lastNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter your last name");
    } else if (userNameEmailController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter your Email/Phone Number");
    } else if (passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter your Password");
    } else if (confirmPasswordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter your confirm password");
    } else {
      Fluttertoast.showToast(msg: "Your credential have been taken");
    }
  }
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    userNameEmailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 30, color: Colors.blueAccent),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("First Name"),
                          ),
                          TextField(
                            controller: firstNameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              hintText: "Enter Your First Name",
                              hintStyle: TextStyle(color: Colors.black38),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 19),
                    Expanded(
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Middle/Last Name"),
                          ),
                          TextField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              hintText: "Enter your Last Name",
                              hintStyle: TextStyle(color: Colors.black38),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email/Phone Number"),
                ),
                TextField(
                  controller: userNameEmailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.mail),
                    border: OutlineInputBorder(),
                    hintText: "Enter your Email/Phone Number",
                    hintStyle: TextStyle(color: Colors.black38),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Password"),
                ),
                TextField(
                  obscureText: obscure,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Enter your strong Password",
                    hintStyle: const TextStyle(color: Colors.black38),
                    prefixIcon: const Icon(Icons.password),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                      child: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Confirm Password"),
                ),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Confirm your Password",
                    hintStyle: const TextStyle(color: Colors.black38),
                    prefixIcon: const Icon(Icons.password),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                      child: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Back")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          signUpValidation();
                        },
                        child: const Text("Sign In"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
