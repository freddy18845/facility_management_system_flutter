import 'package:flutter/material.dart';

Widget buildSection({
  required String title,
  required IconData icon,
  required Color color,
  required List<Widget> children,
  required BuildContext context
}) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    ),
  );
}

Widget buildListTile({
  required IconData icon,
  required String title,
  String? subtitle,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  return ListTile(
    leading: Icon(icon, size: 22, color: Colors.grey.shade700),
    title: Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    subtitle: subtitle != null
        ? Text(
      subtitle,
      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
    )
        : null,
    trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
    onTap: onTap,
    dense: true,
  );
}