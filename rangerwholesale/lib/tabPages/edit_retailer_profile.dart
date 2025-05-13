import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/provider/edit_profile_provider.dart';
import 'package:rangerwholesale/provider/retailer_profile_provider.dart';

class EditRetailer extends StatefulWidget {
  EditRetailer({super.key});

  @override
  _EditRetailerState createState() => _EditRetailerState();
}

class _EditRetailerState extends State<EditRetailer> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Image files
  File? _profileImage;
  File? _driverLicenseImage;
  File? _tobaccoPermitImage;
  File? _salesTaxIdImage;

  // Text controllers
  final TextEditingController _retailerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _primaryNumberController = TextEditingController();
  final TextEditingController _secondaryNumberController = TextEditingController();
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _addressMobileController = TextEditingController();
  final TextEditingController _addressStreetController = TextEditingController();
  final TextEditingController _addressCityController = TextEditingController();
  final TextEditingController _addressPincodeController = TextEditingController();
  final TextEditingController _addressStateController = TextEditingController();
  final TextEditingController _addressProvinceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchProfileData());
  }

  Future<void> _fetchProfileData() async {
    final provider = Provider.of<RetailerProfileProvider>(context, listen: false);
    await provider.fetchProfileData(context);

    if (provider.profileData != null) {
      final data = provider.profileData!['data'];
      final userProfile = data['userProfile'];
      final retailer = data['retailer'];

      setState(() {
        _retailerNameController.text = userProfile['fullName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _primaryNumberController.text = userProfile['phone'] ?? '';
        _secondaryNumberController.text = data['retailer']['secondaryNumber'] ?? '';
        _addressNameController.text = retailer['address']['name'] ?? '';
        _addressMobileController.text = retailer['address']['mobile'] ?? '';
        _addressStreetController.text =retailer['address']['street'] ?? '';
        _addressCityController.text = retailer['address']['city'] ?? '';
        _addressPincodeController.text = retailer['address']['pincode'] ?? '';
        _addressStateController.text = retailer['address']['state'] ?? '';
        _addressProvinceController.text = retailer['address']['province'] ?? '';

        // Load images if available
        if (userProfile['image'] != null) {
          _loadImage(userProfile['image']).then((file) {
            setState(() {
              _profileImage = file;
            });
          });
        }
        if (userProfile['driverLicense'] != null) {
          _loadImage(userProfile['driverLicense']).then((file) {
            setState(() {
              _driverLicenseImage = file;
            });
          });
        }
        if (userProfile['tobaccoPermit'] != null) {
          _loadImage(userProfile['tobaccoPermit']).then((file) {
            setState(() {
              _tobaccoPermitImage = file;
            });
          });
        }
        if (userProfile['salesTaxId'] != null) {
          _loadImage(userProfile['salesTaxId']).then((file) {
            setState(() {
              _salesTaxIdImage = file;
            });
          });
        }
      });
    }
  }

  Future<File?> _loadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final file = File('${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        file.writeAsBytesSync(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return null;
  }

  // Image picker method
  Future<void> _pickImage(ImageSource source, Function(File?) onImagePicked) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        setState(() {
          onImagePicked(compressedFile);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image compression failed. Using original image.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          onImagePicked(originalFile);
        });
      }
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 70,
      );

      if (compressedBytes == null) {
        return null;
      }

      File compressedFile = File('${imageFile.path}_compressed.jpg')
        ..writeAsBytesSync(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Image compression error: $e');
      return null;
    }
  }

  // Image selection bottom sheet
  void _showImagePickerBottomSheet(Function(File?) onImagePicked) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImagePickerOption(
              icon: Icons.photo_library,
              text: 'Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, onImagePicked);
              },
            ),
            _buildImagePickerOption(
              icon: Icons.camera_alt,
              text: 'Camera',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, onImagePicked);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Image picker option widget
  Widget _buildImagePickerOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.black54),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Profile Image upload widget
  Widget _buildProfileImageUploadField({
    required File? imageFile,
    required Function(File?) onImagePicked,
  }) {
    return Center(
      child: GestureDetector(
        onTap: () => _showImagePickerBottomSheet(onImagePicked),
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: imageFile == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 40, color: Colors.grey.shade500),
              const SizedBox(height: 10),
              Text(
                'Upload Profile Photo',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          )
              : ClipOval(
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }

  // Document Image upload widget
  Widget _buildDocumentImageUploadField({
    required File? imageFile,
    required String label,
    required Function(File?) onImagePicked,
  }) {
    return GestureDetector(
      onTap: () => _showImagePickerBottomSheet(onImagePicked),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: imageFile == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 60, color: Colors.grey.shade500),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        )
            : Image.file(imageFile, fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Update Profile",
            style: TextStyle(
              fontFamily: "poppins",
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Consumer<RetailerProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.mainAppColor,
                  size: 40,
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Text('Error: ${provider.error}'),
              );
            }

            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Image Upload
                        _buildProfileImageUploadField(
                          imageFile: _profileImage,
                          onImagePicked: (file) => _profileImage = file,
                        ),
                        const SizedBox(height: 20),

                        // Personal Details
                        _buildSectionTitle('Personal Details'),
                        TextFormField(
                          controller: _retailerNameController,
                          decoration: _inputDecoration('Retailer Name'),
                          validator: _validateRetailerName,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _primaryNumberController,
                          decoration: _inputDecoration('Primary Number'),
                          keyboardType: TextInputType.phone,
                          validator: _validatePrimaryPhone,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _secondaryNumberController,
                          decoration: _inputDecoration('Secondary Number'),
                          keyboardType: TextInputType.phone,
                          validator: _validateSecondaryPhone,
                        ),
                        // Address Details
                        const SizedBox(height: 20),
                        _buildSectionTitle('Address Details'),
                        TextFormField(
                          controller: _addressNameController,
                          decoration: _inputDecoration('Address Name'),
                          // validator: _validateContactName,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _addressMobileController,
                          decoration: _inputDecoration('Mobile Number'),
                          keyboardType: TextInputType.phone,
                          // validator: _validateAddressMobile,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _addressStreetController,
                          decoration: _inputDecoration('Street Address'),
                          // validator: _validateStreetAddress,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _addressCityController,
                          decoration: _inputDecoration('City'),
                          validator: _validateCity,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _addressPincodeController,
                          decoration: _inputDecoration('Pincode'),
                          keyboardType: TextInputType.number,
                          validator: _validatePincode,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _addressStateController,
                          decoration: _inputDecoration('State'),
                          validator: _validateState,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _addressProvinceController,
                          decoration: _inputDecoration('Province'),
                          // validator: _validateProvince,
                        ),

                        // Document Uploads
                        const SizedBox(height: 20),
                        _buildSectionTitle('Document Uploads'),
                        _buildDocumentImageUploadField(
                          imageFile: _driverLicenseImage,
                          label: 'Upload Driver License',
                          onImagePicked: (file) => _driverLicenseImage = file,
                        ),
                        if (_driverLicenseImage == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Driver License is required',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 15),
                        _buildDocumentImageUploadField(
                          imageFile: _tobaccoPermitImage,
                          label: 'Upload Tobacco Permit',
                          onImagePicked: (file) => _tobaccoPermitImage = file,
                        ),
                        if (_tobaccoPermitImage == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Tobacco Permit is required',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 15),
                        _buildDocumentImageUploadField(
                          imageFile: _salesTaxIdImage,
                          label: 'Upload Sales Tax ID',
                          onImagePicked: (file) => _salesTaxIdImage = file,
                        ),
                        if (_salesTaxIdImage == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Sales Tax ID is required',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),

                        // Submit Button
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  // Input decoration method
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black54, width: 1.5),
      ),
    );
  }

  // Section title method
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.mainAppColor,
        ),
      ),
    );
  }


  // Comprehensive Validation Methods
  String? _validateRetailerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Retailer name is required';
    }
    if (value.trim().length < 2) {
      return 'Retailer name must be at least 2 characters long';
    }
    // Regex to allow only letters, spaces, and hyphens
    final nameRegex = RegExp(r'^[a-zA-Z\s-]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Retailer name can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePrimaryPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Primary number is required';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateSecondaryPhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\d{10}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return 'Please enter a valid 10-digit phone number';
      }
    }
    return null;
  }

  String? _validateContactName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact name is required';
    }
    if (value.trim().length < 2) {
      return 'Contact name must be at least 2 characters long';
    }
    // Regex to allow only letters, spaces, and hyphens
    final nameRegex = RegExp(r'^[a-zA-Z\s-]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Contact name can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  // Remaining Validation Methods
  String? _validateAddressMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validateStreetAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Street address is required';
    }
    return null;
  }


  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    final pincodeRegex = RegExp(r'^\d{4,7}$');
    if (!pincodeRegex.hasMatch(value.trim())) {
      return 'Enter a valid pincode (4 to 7 digits)';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'State is required';
    }
    if (value.trim().length < 2) {
      return 'State name must be at least 2 characters long';
    }
    // Regex to allow only letters and spaces
    final stateRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!stateRegex.hasMatch(value.trim())) {
      return 'State name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateProvince(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Province is required';
    }
    if (value.trim().length < 2) {
      return 'Province name must be at least 2 characters long';
    }
    // Regex to allow only letters and spaces
    final provinceRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!provinceRegex.hasMatch(value.trim())) {
      return 'Province name can only contain letters and spaces';
    }
    return null;
  }

  // Form submission method with comprehensive validation
  void _submitForm() async {
    bool hasAllDocuments = _driverLicenseImage != null &&
        _tobaccoPermitImage != null &&
        _salesTaxIdImage != null;

    if (_formKey.currentState!.validate()) {
      if (!hasAllDocuments) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload all required documents'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = Provider.of<EditRetailerProvider>(
          context,
          listen: false
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: AppColors.mainAppColor,
              size: 40,
            ),
          );
        },
      );

      bool success = await provider.editRetailer(
        retailerName: _retailerNameController.text.trim(),
        email: _emailController.text.trim(),
        primaryNumber: _primaryNumberController.text.trim(),
        secondaryNumber: _secondaryNumberController.text.trim(),
        addressName: _addressNameController.text.trim(),
        addressMobile: _addressMobileController.text.trim(),
        streetAddress: _addressStreetController.text.trim(),
        city: _addressCityController.text.trim(),
        pincode: _addressPincodeController.text.trim(),
        state: _addressStateController.text.trim(),
        province: _addressProvinceController.text.trim(),
        profileImage: _profileImage,
        driverLicenseImage: _driverLicenseImage!,
        tobaccoPermitImage: _tobaccoPermitImage!,
        salesTaxIdImage: _salesTaxIdImage!,
        context: context,  // Add this line
      );

      Navigator.of(context).pop();

      if (success) {
        Fluttertoast.showToast(
          msg: "Profile Updated Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: provider.errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  // Optional: Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _retailerNameController.dispose();
    _emailController.dispose();
    _primaryNumberController.dispose();
    _secondaryNumberController.dispose();
    _addressNameController.dispose();
    _addressMobileController.dispose();
    _addressStreetController.dispose();
    _addressCityController.dispose();
    _addressPincodeController.dispose();
    _addressStateController.dispose();
    _addressProvinceController.dispose();
    super.dispose();
  }
}