// retailer_listing_page.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/auth/sign_up.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/wholeseller_view/retailer_detail_page.dart';
import 'package:rangerwholesale/wholeseller_view/provider/retailer_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RetailerListingPage extends StatefulWidget {
  const RetailerListingPage({Key? key}) : super(key: key);

  @override
  _RetailerListingPageState createState() => _RetailerListingPageState();
}

class _RetailerListingPageState extends State<RetailerListingPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool isSuperUser = false;

  @override
  void initState() {
    super.initState();
    _loadSuperUserStatus();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RetailerProvider>(context, listen: false);
      provider.resetState();
      provider.fetchRetailers(refresh: true,context: context);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuperUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isSuperUser = prefs.getBool("is_superuser") ?? false;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final retailerProvider = Provider.of<RetailerProvider>(context, listen: false);
      if (!retailerProvider.isLoading && retailerProvider.hasMoreData) {
        retailerProvider.fetchRetailers(context: context);
      }
    }
  }

  Widget _buildHeaderSection(RetailerProvider retailerProvider) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
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
                Positioned(
                  top: 40.0,
                  left: 80.0,
                  right: 15.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: Center(
                          child: Text(
                            "Retailers",
                            style: TextStyle(
                              fontFamily: "poppins",
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 20.0,
                  right: 20.0,
                  child: _buildSearchSection(retailerProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(RetailerProvider retailerProvider) {
    return TextField(
      controller: _searchController,
      style: const TextStyle(
        fontFamily: "Poppins",
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Search Retailers...',
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontFamily: "Poppins",
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.mainAppColor.withOpacity(0.7),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: Icon(
            Icons.clear,
            color: AppColors.mainAppColor.withOpacity(0.7),
          ),
          onPressed: () {
            _searchController.clear();
            setState(() {
              searchQuery = '';
            });
            retailerProvider.searchRetailers('',context);
          },
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.mainAppColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onChanged: (String value) {
        setState(() {
          searchQuery = value;
        });
        retailerProvider.searchRetailers(searchQuery,context);
      },
      onSubmitted: (String value) {
        retailerProvider.searchRetailers(value,context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Consumer<RetailerProvider>(
          builder: (context, retailerProvider, child) {
            return Column(
              children: [
                _buildHeaderSection(retailerProvider),
                Expanded(
                  child: _buildRetailersList(retailerProvider),
                ),
              ],
            );
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => const RetailerRegistrationPage(),
        //       ),
        //     );
        //   },
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }

  Widget _buildRetailersList(RetailerProvider retailerProvider) {
    if (retailerProvider.isLoading && retailerProvider.retailers.isEmpty) {
      return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          color: AppColors.mainAppColor,
          size: 40,
        ),
      );
    }

    if (retailerProvider.error != null && retailerProvider.retailers.isEmpty) {
      return Center(
        child: Text(retailerProvider.error!),
      );
    }

    if (retailerProvider.retailers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.store_outlined,
              color: Colors.grey,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              'No retailers found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await retailerProvider.fetchRetailers(refresh: true,  context: context);
      },
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: retailerProvider.retailers.length +
              (retailerProvider.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == retailerProvider.retailers.length) {
              if (retailerProvider.isLoading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColors.mainAppColor,
                      size: 40,
                    ),
                  ),
                );
              }
              return const SizedBox();
            }
            return _buildRetailerCard(retailerProvider.retailers[index]);
          },
        ),
      ),
    );
  }
  Widget _buildRetailerCard(dynamic retailer) {
    // Extract verified status from users array
    bool isVerified = retailer['users'] != null &&
        retailer['users'].isNotEmpty &&
        retailer['users'][0]['isVerifiedByAdmin'] == true;

    // Get primary contact information
    String primaryNumber = retailer['users'][0]['userProfile']['phone'] ?? 'No primary number';
    String name = retailer['name'] ?? 'Unnamed Retailer';
    String email = retailer['email'] ?? 'No email provided';

    // Try to get full name from user profile if available
    String fullName = retailer['users'] != null &&
        retailer['users'].isNotEmpty &&
        retailer['users'][0]['userProfile'] != null
        ? retailer['users'][0]['userProfile']['fullName'] ?? name
        : name;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RetailerDetailsPage(retailer: retailer),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainAppColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Verification Button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            isVerified ? null :
                            _showVerificationDialog(context, retailer);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isVerified
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isVerified
                                    ? Colors.green.shade200
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isVerified
                                      ? Icons.verified
                                      : Icons.verified_outlined,
                                  color: isVerified
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified ? 'Verified' : 'Verify',
                                  style: TextStyle(
                                    color: isVerified
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isSuperUser)
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context, retailer),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Divider
                Divider(
                  color: Colors.grey.shade300,
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Contact Information
                _buildInfoRow(
                  Icons.phone_outlined,
                  primaryNumber,
                ),
                _buildInfoRow(
                  Icons.email_outlined,
                  email,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic retailer) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Delete Retailer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to delete ${retailer['name'] ?? 'this Retailer'}? This action cannot be undone.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color: AppColors.mainAppColor,
                        size: 30,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
                ElevatedButton(
                  // Inside the onPressed of the Delete button in _showDeleteDialog
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      final retailerProvider = Provider.of<RetailerProvider>(
                        context,
                        listen: false,
                      );

                      bool success = await retailerProvider.deleteRetailer(
                          retailer['id'],
                          retailer['email'],
                      );

                      if (success) {
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                          msg: "Retailer deleted successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        Fluttertoast.showToast(
                          msg: retailerProvider.error ?? "Failed to delete retailer",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      Fluttertoast.showToast(
                        msg: "An error occurred while deleting",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.red.withOpacity(0.2),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: isLoading ? Colors.grey.shade100 : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showVerificationDialog(BuildContext context, dynamic retailer) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Verify Retailer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to verify ${retailer['name'] ?? 'this Retailer'}? This action cannot be undone.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color: AppColors.mainAppColor,
                        size: 30,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      bool success = await Provider.of<RetailerProvider>(
                        context,
                        listen: false,
                      ).verifyRetailer(retailer['users'][0]['id']);

                      if (success) {
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                          msg: "Retailer verified successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        Fluttertoast.showToast(
                          msg: "Failed to verify retailer",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      Fluttertoast.showToast(
                        msg: "An error occurred while verifying",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.mainAppColor.withOpacity(0.2),
                  ),
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      color: isLoading ? Colors.grey.shade100 : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Placeholder method for retailer verification
  void _verifyRetailer(dynamic retailer) async {
    try {
      bool success = await Provider.of<RetailerProvider>(context, listen: false)
          .verifyRetailer(retailer['users'][0]['id']);

      if (success) {
        Fluttertoast.showToast(
          msg: "Retailer verified successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to verify retailer",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred while verifying",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}