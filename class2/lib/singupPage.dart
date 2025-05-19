

import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Signup Page"),
          backgroundColor: Colors.red,
        ),
        body: Column(
        children: [
      GestureDetector(
          onTap: (){

          },
          child: Text("Go back to login page "))
        ],
        ),
      ),
    );
  }
}
