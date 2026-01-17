import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final bool isSelected;

  const AccountCard({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Container(
      constraints: BoxConstraints(
        maxWidth: isMobile ? size.width * 0.8 : 220,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 20 : 28,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade300,
          width:  1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? Colors.black12 : Colors.grey.shade50,
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 6 : 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue.shade700 : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/$icon',
            height: isMobile ? 40 : 50,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.account_circle,
                size: isMobile ? 40 : 50,
                color: isSelected ? Colors.blue : Colors.grey,
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            description,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              fontStyle: FontStyle.italic,
              color: isSelected ? Colors.blue.shade600 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}