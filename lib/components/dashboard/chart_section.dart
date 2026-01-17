import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fms_app/components/dashboard/progress_bar.dart';

Widget buildChartsSection({required bool isMobile,
  required  Map<String, dynamic> status,
  required  Map<String, dynamic> priority}) {
  if (isMobile) {
    return Column(
      children: [
        buildPriorityChart(priorityBreakdown: priority),
        const SizedBox(height: 16),
        buildStatusChart(statusBreakdown: status),
      ],
    );
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: buildPriorityChart( priorityBreakdown: priority)),
      const SizedBox(width: 16),
      Expanded(child: buildStatusChart(statusBreakdown: status)),
    ],
  );
}

Widget buildPriorityChart({required  Map<String, dynamic> priorityBreakdown}) {
  final total = (priorityBreakdown["low"] ?? 0) +
      (priorityBreakdown["medium"] ?? 0) +
      (priorityBreakdown["high"] ?? 0);

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.pie_chart, color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Priority Breakdown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        buildProgressBar(
          'High Priority',
          priorityBreakdown["high"] ?? 0,
          total,
          Colors.red,
        ),
        const SizedBox(height: 16),
        buildProgressBar(
          'Medium Priority',
          priorityBreakdown["medium"] ?? 0,
          total,
          Colors.orange,
        ),
        const SizedBox(height: 16),
        buildProgressBar(
          'Low Priority',
          priorityBreakdown["low"] ?? 0,
          total,
          Colors.green,
        ),
      ],
    ),
  );
}

Widget buildStatusChart({required  Map<String, dynamic> statusBreakdown}) {
  final total = (statusBreakdown["pending"] ?? 0) +
      (statusBreakdown["assigned"] ?? 0) +
      (statusBreakdown["in_progress"] ?? 0);

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.bar_chart, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Active Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        buildProgressBar(
          'Pending',
          statusBreakdown["pending"] ?? 0,
          total,
          Colors.yellow.shade700,
        ),
        const SizedBox(height: 16),
        buildProgressBar(
          'Assigned',
          statusBreakdown["assigned"] ?? 0,
          total,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        buildProgressBar(
          'In Progress',
          statusBreakdown["in_progress"] ?? 0,
          total,
          Colors.purple,
        ),
      ],
    ),
  );
}