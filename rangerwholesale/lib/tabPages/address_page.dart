import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/provider/getAddressProvider.dart';

class AddressPage extends StatefulWidget {
  final int? id;

  const AddressPage({super.key, this.id});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _fullNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AddressProviderGet>(context, listen: false);
      provider.fetchAddress(context).then((_) {
        final address = provider.addressListing?.data?.isNotEmpty ?? false
            ? provider.addressListing!.data![0]
            : null;

        if (address != null) {
          _fullNameController.text = address.name ?? '';
          _mobileNumberController.text = address.mobile ?? '';
          _streetController.text = address.street ?? '';
          _cityController.text = address.city ?? '';
          _pincodeController.text = address.pincode ?? '';
          _stateController.text = address.state ?? '';
        }
      });
    });
  }

  void _updateAddress(AddressProviderGet addressProviderGet) {
    if (_formKey.currentState!.validate()) {
      addressProviderGet.updateAddress(
        id: widget.id,
        context: context,
        fullName: _fullNameController.text.trim(),
        mobileNumber: _mobileNumberController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        state: _stateController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Update Address",
            style: TextStyle(
              fontFamily: "Poppins",
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<AddressProviderGet>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.mainAppColor,
                  size: 40,
                ),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Your Shipping Address',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: _fullNameController,
                        label: "Full Name",
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCustomTextField(
                        controller: _mobileNumberController,
                        label: "Mobile Number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mobile number';
                          }
                          if (value.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCustomTextField(
                        controller: _streetController,
                        label: "Street Address",
                        icon: Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter street address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCustomTextField(
                        controller: _cityController,
                        label: "City",
                        icon: Icons.location_city_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCustomTextField(
                        controller: _pincodeController,
                        label: "Pincode",
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pincode';
                          }
                          if (value.length < 4) {
                            return 'Pincode must be at least 4 digits';
                          }
                          if (value.length > 7) {
                            return 'Pincode must not exceed 7 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCustomTextField(
                        controller: _stateController,
                        label: "State",
                        icon: Icons.map_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter state';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Consumer<AddressProviderGet>(
          builder: (context, addressProviderGet, child) {
            return Padding(
              padding:
                  const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
              child: ElevatedButton(
                onPressed: () => _updateAddress(addressProviderGet),
                // onPressed: (){},
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: AppColors.mainAppColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: addressProviderGet.isLoading
                    ? LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.white,
                      size: 20,
                    )
                    : const Text(
                        'Update Address',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontFamily: "Poppins",
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.mainAppColor),
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: "Poppins",
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: const TextStyle(
            fontFamily: "Poppins",
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    super.dispose();
  }
}
