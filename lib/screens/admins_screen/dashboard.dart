import 'dart:convert';
import 'package:flutter/material.dart';
import '../../components/dashboard/chart_section.dart';
import '../../components/dashboard/main_status.dart';
import '../../components/dashboard/shimmer.dart';
import '../../providers/constants.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/recent_incidents.dart';

class DashboardContent extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final bool isMobile;

  const DashboardContent({
    super.key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.isMobile,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent>
    with SingleTickerProviderStateMixin {



  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _dashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _dashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().get('admin/dashboard', context);

      if (response?.statusCode == 200) {
        final responseData = jsonDecode(response!.body);

        setState(() {
          usersData = responseData["stats"]["users"];
          maintenanceData = responseData["stats"]["maintenance"];
          priorityBreakdown = responseData["breakdown"]["by_priority"] ?? {};
          statusBreakdown = responseData["breakdown"]["by_status"] ?? {};
          isLoading = false;
        });

        // Start animations after data loads
        _animationController.forward();
      } else {
        final responseData = jsonDecode(response!.body);
        setState(() {
          isLoading = false;
        });
        showCustomSnackBar(context, ' ${responseData["message"]}');
      }
    } catch (e) {
      print('❌ API connection failed: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showCustomSnackBar(context, 'Network Error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _dashboardData,
      color: Theme.of(context).primaryColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: isLoading ? _buildLoadingState() : _buildDashboard(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          buildShimmerHeader(),
          const SizedBox(height: 24),
          buildShimmerCards(verticalPadding: widget.verticalPadding,horizontalPadding:widget.horizontalPadding  ,isMobile: widget.isMobile),
          const SizedBox(height: 24),
          buildShimmerChart(),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Main KPI Cards with staggered animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
          child: MainStatus(
              horizontalPadding: widget.horizontalPadding,
              verticalPadding: widget.verticalPadding,
              isMobile: widget.isMobile,

            openComplaints: maintenanceData["open"].toString(),
            usersTotal:usersData["staff"].toString() ,
            artisanTotal: usersData["artisans"].toString(),
            tenantsTotal: usersData["tenants"].toString(),
            sms: 'sms',),
            ),
          ),
          const SizedBox(height: 16),

          // Charts Section
          FadeTransition(
            opacity: _fadeAnimation,
            child: buildChartsSection(
                isMobile: widget.isMobile,
              priority: priorityBreakdown,
              status: statusBreakdown
            ),
          ),
          const SizedBox(height: 16),

          // Recent Incidents
          FadeTransition(
            opacity: _fadeAnimation,
            child: RecentIncidents(
              isMobile: widget.isMobile,
              height: widget.verticalPadding * 19.5,
            ),
          ),
        ],
      ),
    );
  }

}