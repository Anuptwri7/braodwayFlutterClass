import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/tabPages/address_view.dart';
import 'package:rangerwholesale/tabPages/edit_retailer_profile.dart';
import 'package:rangerwholesale/wholeseller_view/provider/retailer_provider.dart';
import '../auth/auth_handler.dart';
import '../auth/loginScreen.dart';
import '../const/styleConst.dart';
import '../provider/login_provider.dart';
import '../provider/retailer_profile_provider.dart';
import 'change_password.dart';
import 'my_orders.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RetailerProfileProvider>(context, listen: false).fetchProfileData(context);
    });
  }

  void _logout() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final profileProvider = Provider.of<RetailerProfileProvider>(context, listen: false);

    await loginProvider.logout();
    profileProvider.clearProfileData();
    await TokenManager.instance.clearTokens();

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Widget _buildProfileHeader(RetailerProfileProvider profileProvider) {
    if (profileProvider.isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(40.0),
            bottomLeft: Radius.circular(40.0),
          ),
          color: AppColors.mainAppColor,
        ),
        height: 200.0,
        child: Stack(
          children: <Widget>[
            const Positioned(
              top: 35.0,
              left: 35.0,
              right: 15.0,
              child: Center(
                child: Text(
                  "My Profile",
                  style: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40.0,
              left: 40.0,
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40.0),
          bottomLeft: Radius.circular(40.0),
        ),
        color: AppColors.mainAppColor,
      ),
      height: 200.0,
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: 35.0,
            left: 35.0,
            right: 15.0,
            child: Center(
              child: Text(
                "My Profile",
                style: TextStyle(
                  fontFamily: "poppins",
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
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
                  backgroundImage: profileProvider.profileImage != null
                      ? NetworkImage(profileProvider.profileImage!)
                      : const AssetImage('assets/icons/appIcon.png') as ImageProvider,
                  child: profileProvider.profileImage == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileProvider.fullName,
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
                        profileProvider.email,
                        style: const TextStyle(
                          fontFamily: "poppins",
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        profileProvider.phone,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<RetailerProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.error != null) {
            return Center(child: Text('Error: ${profileProvider.error}'));
          }

          return Column(
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
                              _buildProfileHeader(profileProvider),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              _buildProfileTile("Edit Profile", Icons.edit_calendar, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditRetailer()),
                                );
                              }),
                              const SizedBox(height: 10),
                              _buildProfileTile("Address", Icons.house_sharp, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddressViewPage()),
                                );
                              }),
                              const SizedBox(height: 10),
                              _buildProfileTile("Change Password", Icons.lock_outline_sharp, () {
                                showChangePasswordDialog(context);
                              }),
                              const SizedBox(height: 10),
                              _buildProfileTile("My Orders", Icons.list_alt, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MyOrders()),
                                );
                              }),
                              const SizedBox(height: 10),
                              _buildProfileTile("Deactivate Account", Icons.delete_forever_rounded, () {
                                showDeleteAccountDialog(profileProvider.id, context);
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
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      backgroundColor: AppColors.mainAppColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, color: Colors.white),
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
              const SizedBox(height: 20),
            ],
          );
        },
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
              style: const TextStyle(
                  fontFamily: "poppins", fontSize: 18, color: Colors.black),
            ),
            trailing:
            const Icon(Icons.arrow_forward_ios_sharp, color: Colors.black),
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
                  style: TextStyle(
                      fontFamily: "poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
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

  void showDeleteAccountDialog(int retailerId, BuildContext context) {
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
                    Icons.delete_forever_rounded,
                    color: AppColors.mainAppColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Deactivate Account',
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.mainAppColor,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to deactivate your account? This action cannot be undone.',
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
                        onPressed: () async{
                          bool success = await Provider.of<RetailerProvider>(
                            context,
                            listen: false,
                          ).deactivateAccount(retailerId);

                          if (success) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Account deactivated successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );

                            final loginProvider = Provider.of<LoginProvider>(context, listen: false);
                            final profileProvider = Provider.of<RetailerProfileProvider>(context, listen: false);

                            await loginProvider.logout();
                            profileProvider.clearProfileData();
                            await TokenManager.instance.clearTokens();

                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (route) => false,
                            );
                          } else {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Failed to deactivate account",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
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