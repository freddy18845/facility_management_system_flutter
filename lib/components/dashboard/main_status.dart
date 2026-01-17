import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainStatus extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final bool isMobile;
  final String openComplaints;
  final String usersTotal;
  final String artisanTotal;
  final String tenantsTotal;
  final String sms;
  const MainStatus({
    super.key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.isMobile,
    required this.openComplaints,
    required this.usersTotal,
    required this.artisanTotal,
    required this.tenantsTotal,
    required this.sms,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: horizontalPadding * 0.3,
      runSpacing: verticalPadding,
      children: [
        _buildEnhancedStatCard(
          title: 'Open Complaints',
          value: openComplaints,
          icon: Icons.report_gmailerrorred,
          color: Colors.red,
          isMobile: isMobile,
          // subtitle: '${maintenanceData["overdue"]} overdue',
        ),
        _buildEnhancedStatCard(
          title: 'Total Artisans',
          value: artisanTotal,
          icon: Icons.engineering_outlined,
          color: Colors.blue,
          isMobile: isMobile,
        ),
        _buildEnhancedStatCard(
          title: 'Total Tenants',
          value: tenantsTotal,
          icon: Icons.apartment_outlined,
          color: Colors.green,
          isMobile: isMobile,
        ),
        if (!isMobile)
          _buildEnhancedStatCard(
            title: 'Total Users',
            value: usersTotal,
            icon: Icons.group_outlined,
            color: Colors.purple,
            isMobile: isMobile,
          ),
        _buildEnhancedStatCard(
          title: 'Total SMS',
          value: '200',
          icon: Icons.message_outlined,
          color: Colors.orange,
          isMobile: isMobile,
        ),
      ],
    );
  }
}

Widget _buildEnhancedStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  required bool isMobile,
  String? subtitle,
}) {
  return Container(
    width: isMobile ? double.infinity : 230,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
      ],
    ),
  );
}
