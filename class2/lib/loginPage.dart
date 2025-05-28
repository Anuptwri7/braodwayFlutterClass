import 'dart:convert';
import 'dart:developer';
import 'package:class2/tabPages.dart';
import 'package:http/http.dart' as http;
import 'package:class2/homepage.dart';
import 'package:class2/singupPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obsecure = true;

  Future postLogin() async {

    final response = await http.post(
      Uri.parse('https://api-barrel.sooritechnology.com.np/api/v1/user-app/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(
          {
            "userName": emailController.text,
            "password": passwordController.text
          }
      ));

      if(response.statusCode==200){
        SharedPreferences prefs =await SharedPreferences.getInstance();

        log(jsonDecode(response.body)['userName']);
        prefs.setString("username",jsonDecode(response.body)['userName']);
        prefs.setInt("id",jsonDecode(response.body)['id']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Mainpage()));
      }else{
        Fluttertoast.showToast(msg: "Invalid");
      }





    return response;
  }


  void _validation(){

    if(emailController.text.isEmpty){
      Fluttertoast.showToast(msg: "Please enter the email");
    }
    else if(passwordController.text.isEmpty){
      Fluttertoast.showToast(msg: "Please enter the password");
    }
    else
    {
      Fluttertoast.showToast(msg: emailController.text);
    }
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
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

                TextFormField(

                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    prefixIcon: Icon(Icons.email),

                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Color(0xffcbcbcb)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Color(0xffBF1E2E)),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  obscureText: _obsecure,
                  controller: passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.password),
                    suffixIcon: GestureDetector(
                        onTap: (){
                          if(_obsecure==true){
                            setState(() {
                              _obsecure=false;
                            });
                          }else if(_obsecure==false){
                           setState(() {
                             _obsecure=true;
                           });
                          }else{
                          setState(() {
                            _obsecure=true;
                          });
                          }
                          log(_obsecure.toString());
                        },
                        child: Icon(_obsecure==true?Icons.remove_red_eye:Icons.remove_red_eye_outlined)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Color(0xffcbcbcb)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Color(0xffBF1E2E)),
                    ),
                  ),
                ),
                SizedBox(height: 120,),
                Center(
                  child: ElevatedButton(
                      onPressed: () async{


                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Mainpage()));
                        postLogin();
                    // _validation();
                  },

                      child: Text("Login")),
                ),
                SizedBox(height: 20,),

                GestureDetector(
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>SignupPage()));
                    log("I am pressed");
                  },
                  child: Center(
                    child: Text("New user ? Signup"),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}







