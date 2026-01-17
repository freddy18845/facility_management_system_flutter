import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QueryButton extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onPressed;

  const QueryButton({required this.isMobile, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Query',
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}