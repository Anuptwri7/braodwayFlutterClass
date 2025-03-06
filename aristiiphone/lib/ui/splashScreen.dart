import 'package:aristiiphone/ui/welcomePage.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashOrMainScreen extends StatelessWidget {
  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    return isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == true) {
          return OnboardingScreen();
        } else {
          return SplashPage();
        }
      },
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  void _completeOnboarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SplashPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Aristi Authenticator",
          body: "Secure Your Digital World with Ease \n\n\n Experience next-level security with our simple and reliable multi-factor authentication (MFA) system. Protect your accounts with cutting-edge technology designed for everyone. ",
          image: Center(child: Image.asset('assets/logoMfa.jpeg',height: 60,)),
        ),
        PageViewModel(
          title: "Why Choose Us?",
          body: "🔒 Reliable Security: Your data stays protected 24/7. \n\n\n ⚡ Easy to Use: Intuitive setup and seamless login. \n\n\n 🌍 Always Accessible: Sync across devices for convenience.",
          image: Center(child: Image.asset('assets/logoMfa.jpeg',height: 60,)),
        ),
        PageViewModel(
          title: "Get Started Now!",
          body: "Take control of your security.\n\n\n Set up your authenticator in minutes and enjoy peace of mind knowing your accounts are safe.",
          image: Center(child: Image.asset('assets/logoMfa.jpeg',height: 60,)),
        ),
      ],
      onDone: () => _completeOnboarding(context),
      showSkipButton: true,
      skip: Text("Skip",style: TextStyle(color: Color(0xffBE202F)),),
      next: Icon(Icons.arrow_forward),
      done: Text("Done", style: TextStyle(fontWeight: FontWeight.w600,color: Color(0xffBE202F))),
    dotsDecorator: DotsDecorator(
    size: Size(10, 10),
    color: Colors.grey, // Inactive dot color
    activeSize: Size(22, 10),
    activeColor: Color(0xffBE202F), // Active dot color
    activeShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(25.0),
    )),
    );
  }
}


