import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/auth/loginScreen.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/provider/login_provider.dart';
import 'package:rangerwholesale/provider/profile_provider.dart';
import 'package:rangerwholesale/tabPages/change_password.dart';
import 'package:rangerwholesale/tabPages/edit_profile.dart';
import 'package:rangerwholesale/wholeseller_view/wholeseller_order_page.dart';
class WholeSellerProfilePage extends StatefulWidget {
  const WholeSellerProfilePage({super.key});

  @override
  State<WholeSellerProfilePage> createState() => _WholeSellerProfilePageState();
}

class _WholeSellerProfilePageState extends State<WholeSellerProfilePage> {

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfileData(context);
    });
  }

  void _logout() async {
    await Provider.of<LoginProvider>(context, listen: false).logout();
    Navigator.of(context ,rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profileModel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 20.0),
                            alignment: Alignment.topCenter,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                                bottomRight: Radius.circular(40.0),
                                bottomLeft: Radius.circular(40.0),
                              ),
                              color: AppColors.mainAppColor,
                            ),
                            height: 200.0,
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: 45.0,
                                  left: 35.0,
                                  right: 15.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "My Profile",
                                            style: TextStyle(
                                                fontFamily: "poppins",
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 40.0,
                                  left: 20.0,
                                  right: 20.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 30,
                                        backgroundImage: profile?.data?.userProfile?.image != null
                                            ? NetworkImage(profile?.data?.userProfile?.image ?? '')
                                            : const AssetImage('assets/icons/appIcon.png') as ImageProvider,
                                        child: profile?.data?.userProfile?.image == null
                                            ? const Icon(Icons.person, color: Colors.grey)
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              profile?.data?.userProfile?.fullName ?? "UserName",
                                              style: const TextStyle(
                                                fontFamily: "poppins",
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              profile?.data?.email ?? "email@example.com",
                                              style: const TextStyle(
                                                fontFamily: "poppins",
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              profile?.data?.userProfile?.phone ?? "**********",
                                              style: const TextStyle(
                                                fontFamily: "poppins",
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildProfileTile("Edit Profile", Icons.edit_calendar, () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(profile: profile!)));
                          }),
                          const SizedBox(height: 10),
                          _buildProfileTile("Change Password", Icons.lock_outline_sharp, () {
                            showChangePasswordDialog(context);
                          }),
                          const SizedBox(height: 10),
                          _buildProfileTile("Orders", Icons.list_alt, () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WholeSellerOrderPage(show: true,)));
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 20.0),
        child: SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              elevation: 10,
              backgroundColor: AppColors.mainAppColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "Logout",
                  style: TextStyle(fontFamily: "poppins", fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildProfileTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.black),
            title: Text(
              title,
              style: const TextStyle(fontFamily: "poppins", fontSize: 18, color: Colors.black),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_sharp, color: Colors.black),
          ),
          const Divider(height: 1.0, color: Colors.grey),
        ],
      ),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainAppColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.mainAppColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Change Password',
                  style: TextStyle(fontFamily: "poppins", fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              'Do you want to change your password?',
              style: TextStyle(fontFamily: "poppins", fontSize: 16),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button background color
                          side: const BorderSide(
                            color: AppColors.mainAppColor, // Border color
                            width: 2, // Border width
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'No',
                            style: TextStyle(
                              fontFamily: "poppins",
                              color: AppColors.mainAppColor, // Text color
                              fontWeight: FontWeight.bold, // Optional: make the text bold
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChangePassword()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Yes',
                            style:
                            TextStyle(fontFamily: "poppins", color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
