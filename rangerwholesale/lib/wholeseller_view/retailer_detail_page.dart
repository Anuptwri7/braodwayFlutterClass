import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/wholeseller_view/provider/retailer_provider.dart';

class RetailerDetailsPage extends StatelessWidget {
  final dynamic retailer;

  const RetailerDetailsPage({Key? key, required this.retailer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProfile = retailer['users'] != null && retailer['users'].isNotEmpty
        ? retailer['users'][0]['userProfile']
        : null;

    final bool isVerified = retailer['users'] != null &&
        retailer['users'].isNotEmpty &&
        retailer['users'][0]['isVerifiedByAdmin'] == true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                if (!isVerified)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color:Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showVerificationDialog(context, retailer),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.verified_outlined,
                                  color: AppColors.mainAppColor,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Verify',
                                  style: TextStyle(
                                    color: AppColors.mainAppColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
              expandedHeight: 300,
              floating: false,
              pinned: true,
              flexibleSpace: Stack(
                children: [
                  FlexibleSpaceBar(
                    background: _buildProfileHeader(userProfile, retailer),
                  ),
                ],
              ),
              backgroundColor: AppColors.mainAppColor,
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildContactCard(retailer),

                  const SizedBox(height: 20),

                  _buildSectionCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow('Full Name', userProfile?['fullName'] ?? 'N/A'),
                      _buildInfoRow('Email', retailer['email'] ?? 'N/A'),
                      _buildInfoRow('Primary Phone',  retailer['users'][0]['userProfile']['phone'] ?? 'N/A'),
                      _buildInfoRow('Secondary Phone', retailer['secondaryNumber'] ?? 'N/A'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildSectionCard(
                    title: 'Account Status',
                    icon: Icons.info_outline,
                    children: [
                      _buildInfoRow('Account Type', retailer['users'][0]['userType'] ?? 'N/A'),
                      _buildInfoRow('Active Status',
                          retailer['users'][0]['isActive'] ? 'Active' : 'Inactive'),
                      _buildInfoRow('Admin Verification',
                          retailer['users'][0]['isVerifiedByAdmin'] ? 'Verified' : 'Not Verified'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildDocumentsSection(context,userProfile),
                ]),
              ),
            ),
          ],
        ),
      ),
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
                        Navigator.of(context).pop(); // Go back to listing page
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

  Widget _buildProfileHeader(dynamic userProfile, dynamic retailer) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.mainAppColor, AppColors.mainAppColor.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'retailer_avatar_${retailer['id']}',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  image: userProfile?['image'] != null
                      ? DecorationImage(
                    image: NetworkImage(userProfile['image']),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: userProfile?['image'] == null
                    ? const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white
                )
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userProfile?['fullName'] ?? retailer['name'] ?? 'Retailer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                retailer['users'][0]['isVerifiedByAdmin'] ? const Icon(Icons.verified,color: Colors.white,) : const Icon(Icons.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Contact Card
  Widget _buildContactCard(dynamic retailer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mainAppColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.contact_phone,
                color: AppColors.mainAppColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    retailer['users'][0]['userProfile']['phone'] ?? 'No Phone',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainAppColor,
                    ),
                  ),
                  Text(
                    retailer['email'] ?? 'No Email',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generic Section Card
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.mainAppColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:AppColors.mainAppColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Info Row Helper
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context, dynamic userProfile) {
    final documents = [
      {'title': "Driver's License", 'url': userProfile?['driverLicense']},
      {'title': 'Tobacco Permit', 'url': userProfile?['tobaccoPermit']},
      {'title': 'Sales Tax ID', 'url': userProfile?['salesTaxId']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Document Photos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.mainAppColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return false;
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: documents.map((doc) {
                return doc['url'] != null
                    ? _buildDocumentThumbnail(context,doc['title'] as String, doc['url'] as String)
                    : const SizedBox.shrink();
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentThumbnail(BuildContext context, String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FullScreenImageViewer(
                imageUrl: imageUrl,
                title: title,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 160,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void navigateToRetailerDetails(BuildContext context, dynamic retailer) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => RetailerDetailsPage(retailer: retailer),
    ),
  );
}
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImageViewer({
    Key? key,
    required this.imageUrl,
    required this.title
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}