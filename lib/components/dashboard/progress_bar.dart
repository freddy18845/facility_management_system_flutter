import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildProgressBar(String label, int count, int total, Color color) {
  final percentage = total > 0 ? (count / total * 100).round() : 0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$count (${percentage}%)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(
            begin: 0,
            end: total > 0 ? count / total : 0,
          ),
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ),
    ],
  );
}
