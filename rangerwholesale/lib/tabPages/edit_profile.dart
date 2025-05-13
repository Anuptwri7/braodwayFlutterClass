import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../const/styleConst.dart';
import '../model/profile_model.dart';
import '../provider/profile_provider.dart';

class EditProfile extends StatefulWidget {
  final ProfileModel profile; // Accept the profile data

  const EditProfile({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _image; // To store the selected image
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // Controllers to pre-fill form fields
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileNumberController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing profile data
    _fullNameController = TextEditingController(
      text: widget.profile.data?.userProfile?.fullName ?? "n/a",
    );
    _emailController = TextEditingController(
      text: widget.profile.data?.email ?? "n/a",
    );
    _mobileNumberController = TextEditingController(
      text: widget.profile.data?.userProfile?.phone ?? "n/a",
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Email validation logic
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  // Generic validation for empty fields
  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  // Mobile number validation
  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Mobile number is required";
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Enter a valid 10-digit mobile number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Edit Profile",
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
            padding: const EdgeInsets.all(30.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey, // Wrap fields in a Form widget
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 0.5),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (widget.profile.data?.userProfile?.image != null
                            ? NetworkImage(
                            widget.profile.data!.userProfile!.image!)
                            : const AssetImage('assets/icons/appIcon.png'))
                        as ImageProvider,
                        child: _image == null &&
                            widget.profile.data?.userProfile?.image == null
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      hintText: "Enter your full name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) => _validateField(value, "Full Name"),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _mobileNumberController,
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      hintText: "Enter your mobile number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: _validateMobileNumber,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 40.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profileProvider.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            final fullName = _fullNameController.text;
                            final email = _emailController.text;
                            final mobileNumber = _mobileNumberController.text;

                      profileProvider.updateProfileData(
                          context, fullName, email, mobileNumber, _image);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: profileProvider.isLoading ? Colors.grey : AppColors.mainAppColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: profileProvider.isLoading
                      ? LoadingAnimationWidget.threeArchedCircle(
                        color: AppColors.mainAppColor,
                        size: 20,
                      )
                      : const Text(
                    'Update',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
