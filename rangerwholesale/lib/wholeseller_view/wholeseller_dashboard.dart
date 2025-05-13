import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/const/styleConst.dart';
import 'package:rangerwholesale/wholeseller_view/provider/dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class WholeSellerDashboard extends StatefulWidget {
  const WholeSellerDashboard({Key? key}) : super(key: key);

  @override
  State<WholeSellerDashboard> createState() => _WholeSellerDashboardState();
}

class _WholeSellerDashboardState extends State<WholeSellerDashboard> {
  String userName = '';
  String email = '';
  String photo = '';
  bool isLoading = true;

  @override
  void initState() {
    _initializeData();
    log("Ram$userName");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardDataProvider>(context, listen: false)
          .fetchDashboardData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<DashboardDataProvider>(
        builder: (context, dashboardProvider, child) {
          final data = dashboardProvider.dashboardData;

          return data == null
              ? _buildShimmerLoading(context)
              : _buildEnhancedDashboardContent(context, data);
        },
      ),
    );
  }

  Future<void> _initializeData() async {
    await getUserDetail();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    log("User Name: $userName"); // Now this will show the correct value
    log("Email: $email");
    log("Photo: $photo");

    // Fetch dashboard data after getting user details
    if (mounted) {
      Provider.of<DashboardDataProvider>(context, listen: false)
          .fetchDashboardData(context);
    }
  }

  Future<void> getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name") ?? "";
      email = prefs.getString("email") ?? "";
      photo = prefs.getString("photo") ?? "";
    });
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Shimmer for Welcome Section
              _buildShimmerWelcomeSection(),
              const SizedBox(height: 20),

              // Shimmer for Quick Stats
              _buildShimmerQuickStatsSection(),
              const SizedBox(height: 20),

              // Shimmer for Monthly Orders Chart
              _buildShimmerMonthlyOrdersChart(),
              const SizedBox(height: 20),

              // Shimmer for Performance Summary
              _buildShimmerPerformanceSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerWelcomeSection() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerQuickStatsSection() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShimmerStatCard(),
              _buildShimmerStatCard(),
              _buildShimmerStatCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerStatCard() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 22,
          color: Colors.white,
        ),
        const SizedBox(height: 4),
        Container(
          width: 70,
          height: 16,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildShimmerMonthlyOrdersChart() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 200,
                height: 24,
                color: Colors.white,
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Container(
                height: 200,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPerformanceSummary() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 24,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              _buildShimmerPerformanceMetric(),
              const SizedBox(height: 10),
              _buildShimmerPerformanceMetric(),
              const SizedBox(height: 10),
              _buildShimmerPerformanceMetric(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerPerformanceMetric() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 20,
              color: Colors.white,
            ),
          ),
          Container(
            width: 50,
            height: 20,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDashboardContent(
      BuildContext context, Map<String, dynamic> data) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeSection(data),
                const SizedBox(height: 20),
                _buildQuickStatsSection(data),
                const SizedBox(height: 20),
                _buildMonthlyOrdersChart(data),
                const SizedBox(height: 20),
                _buildPerformanceSummary(data),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(Map<String, dynamic> data) {
    // Default fallback image URL
    const String fallbackImageUrl =
        "https://img.freepik.com/premium-vector/businessman-avatar-illustration-cartoon-user-portrait-user-profile-icon_118339-4382.jpg";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          photo.isNotEmpty && photo != '#'
              ? CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              photo,
            ),
            backgroundColor: Colors.white,
            onBackgroundImageError: (exception, stackTrace) {
              log('Error loading profile image: $exception');
            },
          )
              : CircleAvatar(
            radius: 40,
            backgroundImage: const NetworkImage(
              fallbackImageUrl,
            ),
            backgroundColor: Colors.white,
            onBackgroundImageError: (exception, stackTrace) {
              log('Error loading profile image: $exception');
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userName.isNotEmpty && userName != '#' ? userName : 'Wholesaler'}',
                  style: TextStyle(
                    color: AppColors.mainAppColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email.isNotEmpty && email != '#'
                      ? email
                      : 'No email provided',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
              icon: Icons.verified_user,
              title: "Approved\nRetailers",
              value: data['data']?['retailers']?['approvedRetailers']
                  ?.toString() ??
                  '0',
              color: Colors.green.shade50,
              textColor: Colors.green.shade800,
            ),
            _buildStatCard(
              icon: Icons.pending,
              title: "Unapproved\nRetailers",
              value: data['data']?['retailers']?['unapprovedRetailers']
                  ?.toString() ??
                  '0',
              color: Colors.red.shade50,
              textColor: Colors.red.shade800,
            ),
            _buildStatCard(
              icon: Icons.shopping_cart,
              title: "Total\nOrders",
              value: data['data']?['orders']?['allTime']?['totalOrders']
                  ?.toString() ??
                  '0',
              color: Colors.blue.shade50,
              textColor: Colors.blue.shade800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Icon(icon, color: textColor, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyOrdersChart(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Monthly Orders Trend",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.mainAppColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 0, bottom: 8),
            child: _buildBarChart(data),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.mainAppColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceMetric(
              icon: Icons.trending_up,
              title: 'Today Order',
              value:
              '${data['data']?['orders']?['today']?['totalOrders'] ?? '0'}',
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            _buildPerformanceMetric(
              icon: Icons.monetization_on,
              title: 'Current Year Order',
              value:
              '${data['data']?['orders']?['currentYear']?['totalOrders'] ?? '0'}',
              color: Colors.blue,
            ),
            const SizedBox(height: 10),
            _buildPerformanceMetric(
              icon: Icons.shopping_basket,
              title: 'All Time Order',
              value:
              '${data['data']?['orders']?['allTime']?['totalOrders'] ?? '0'}',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> data) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _calculateMaxY(data),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toString(), // Changed from rod.y to rod.toY
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const months = [
                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[value.toInt()],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 40,
                interval: 5,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _generateBarGroups(data),
          gridData: FlGridData(
            show: true,
            checkToShowHorizontalLine: (value) => value % 5 == 0,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(Map<String, dynamic> data) {
    final monthlyData = _extractMonthlyData(data);
    final maxValue = monthlyData.values.isNotEmpty
        ? monthlyData.values.reduce((a, b) => a > b ? a : b)
        : 20;
    return maxValue * 1.2;
  }

  Map<String, double> _extractMonthlyData(Map<String, dynamic> data) {
    final monthlyCounts =
        data['data']?['orders']?['currentYear']?['monthlyCounts'] ?? {};

    return {
      'January': monthlyCounts['January']?['total']?.toDouble() ?? 0.0,
      'February': monthlyCounts['February']?['total']?.toDouble() ?? 0.0,
      'March': monthlyCounts['March']?['total']?.toDouble() ?? 0.0,
      'April': monthlyCounts['April']?['total']?.toDouble() ?? 0.0,
      'May': monthlyCounts['May']?['total']?.toDouble() ?? 0.0,
      'June': monthlyCounts['June']?['total']?.toDouble() ?? 0.0,
      'July': monthlyCounts['July']?['total']?.toDouble() ?? 0.0,
      'August': monthlyCounts['August']?['total']?.toDouble() ?? 0.0,
      'September': monthlyCounts['September']?['total']?.toDouble() ?? 0.0,
      'October': monthlyCounts['October']?['total']?.toDouble() ?? 0.0,
      'November': monthlyCounts['November']?['total']?.toDouble() ?? 0.0,
      'December': monthlyCounts['December']?['total']?.toDouble() ?? 0.0,
    };
  }

  List<BarChartGroupData> _generateBarGroups(Map<String, dynamic> data) {
    final monthlyData = _extractMonthlyData(data);
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return monthNames.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      final value = monthlyData[month] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value, // Changed from y to toY
            color: AppColors.mainAppColor, // Changed from colors to color
            gradient: LinearGradient(
              colors: [
                AppColors.mainAppColor.withOpacity(0.4),
                AppColors.mainAppColor,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}