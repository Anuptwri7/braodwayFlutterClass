import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/provider/getAddressProvider.dart';
import 'package:rangerwholesale/tabPages/address_page.dart';

class AddressViewPage extends StatefulWidget {
  const AddressViewPage({super.key});

  @override
  State<AddressViewPage> createState() => _AddressViewPageState();
}

class _AddressViewPageState extends State<AddressViewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AddressProviderGet>(context, listen: false);
      provider.fetchAddress(context);
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: "poppins",
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Address",
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
      body: Consumer<AddressProviderGet>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading) {
            return Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.mainAppColor,
                  size: 40,
                ),
              );
          }

          // Error state
          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // No address found
          if (provider.addressListing?.data == null ||
              provider.addressListing!.data!.isEmpty) {
            return const Center(
              child: Text(
                "No address found",
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 18,
                ),
              ),
            );
          }

          // Address exists
          final address = provider.addressListing!.data![0];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Shipping Address",
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontSize: 18,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                address.name ?? 'Name Not Available',
                                style: const TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.mainAppColor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AddressPage(id:address.id)
                                    )
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            "Mobile",
                            address.mobile ?? 'Not Available'
                        ),
                        _buildInfoRow(
                            "Street",
                            address.street ?? 'Not Available'
                        ),
                        _buildInfoRow(
                            "City",
                            address.city ?? 'Not Available'
                        ),
                        _buildInfoRow(
                            "Pincode",
                            address.pincode ?? 'Not Available'
                        ),
                        _buildInfoRow(
                            "State",
                            address.state ?? 'Not Available'
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}