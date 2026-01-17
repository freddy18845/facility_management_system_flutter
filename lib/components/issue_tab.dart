import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../providers/app_Manager.dart';
import '../screens/dailogs/issue_dailog.dart';
import 'issues_card.dart';

void _showIssueDetails(context, Map<String, dynamic> issue) {
  showDialog(
    context: context,
    builder: (context) => IssueDetailsDialog(issue: issue),
  );
}

Widget buildMyIssuesTab({
  required bool isMobile,
  required BuildContext context,
  required List<Map<String, dynamic>> myIssuesList,
  required VoidCallback onRefresh,
}) {
  final role = AppManager().getRole();
  final size = MediaQuery.of(context).size;

  // Professional Breakpoints
  final bool isTablet = size.width >= 600 && size.width < 1100;
  final bool isArtisan = role == "artisan";

  // --- 1. MOBILE VIEW ---
  if (isMobile) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myIssuesList.length,
      itemBuilder: (context, index) {
        return IssueCard(
          isTablet: isTablet,
          issue: myIssuesList[index],
          isArtisan: isArtisan,
          onTap: () => _showIssueDetails(context, myIssuesList[index]),
          onRefresh: () {},
        );
      },
    );
  }

  // --- 2. TABLET & DESKTOP GRID VIEW ---
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      // 2 columns for Tablet, 3 for Desktop
      crossAxisCount: isTablet ? 2 : 3,
      crossAxisSpacing: isTablet ? 8 : 16,
      mainAxisSpacing: isTablet ? 8 : 16,
      // Adjust this ratio: lower number (1.5) makes cards taller
      childAspectRatio: isTablet ? 1.9 : 1.7,
    ),
    itemCount: myIssuesList.length,
    itemBuilder: (context, index) {
      final issue = myIssuesList[index];
      return IssueCard(
        issue: issue,
        isTablet: isTablet,
        isArtisan: isArtisan,
        onTap: () => _showIssueDetails(context, issue),
        onRefresh: onRefresh,
      );
    },
  );
}
