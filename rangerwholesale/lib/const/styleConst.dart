import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle ralewayStyle = GoogleFonts.raleway();
class AppColors {
  static const Color backgroundColor = Color(0xffF6F6F6);
  static const Color mainAppColor = Color(0xffE62526);
  static const Color buttonColors = Color(0xffE62526);
  static const Color iconColors = Color(0xffE62526);
  static const Color buttonTextColor = Colors.black;
  static const Color greyColor = Color(0xffAAAAAA);
  static const Color whiteColor = Color(0xffFFFFFF);
  static const Color backGroundProduct = Color(0xffF0F9F7);
  static const Color textColorBlack = Color(0xff181725);
}
class AppIcons {
  static const String emailIcon = 'assets/icons/EmailIcon.png';
  static const String lockIcon = 'assets/icons/lockIcon.png';
  static const String eyeIcon = 'assets/icons/EyeIcon.png';
  static const String appIcon = 'assets/icons/appIcon.png';

}
class AppText{
  static const String loginMainText = 'Go ahead and Login ';
  static const String loginSubText = 'to your account';
  static const String loginAdditionalText = 'Sign in-up to enjoy the best grocery Experience';
}


const kFormFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  labelStyle: TextStyle(fontFamily: "poppins",color: Colors.grey,fontSize: 14),
  hintStyle: TextStyle(fontFamily: "poppins",color: Colors.grey,fontSize: 14),
  hintText: 'Answer',
  contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(50.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xffcbcbcb), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(50.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color:Color(0xffcbcbcb), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(50.0)),
  ),
);

const kHeightVeryBigForForm = SizedBox(
  height: 8,
);
const kHeightVeryBig = SizedBox(
  height: 15,
);
const kHeightBig = SizedBox(
  height: 24,
);
const kHeightMedium = SizedBox(
  height: 16,
);
const kHeightSmall = SizedBox(
  height: 8,
);
const kHeightVerySmall = SizedBox(
  height: 4,
);