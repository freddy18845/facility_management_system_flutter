import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

Widget buildDateSelector({
  required String label,
  required DateTime? date,
  required VoidCallback onTap,
  required IconData icon,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            formatDate(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: date != null ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    ),
  );
}