import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
              ),
              Text(
                "Welcome",
                style: TextStyle(
                fontSize: 50,
                color: Colors.red,
                fontWeight: FontWeight.bold
              ),),
              Text("Enter your email and password to login",style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,

              ),),
              SizedBox(height: 120,),
              TextFormField(),
              TextFormField(),
              SizedBox(height: 120,),
              Center(
                child: ElevatedButton(onPressed: (){},
                    child: Text("Login")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
