import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final bool isMobile;
  final bool isShowIcon;

  const CustomButton({
    super.key,
    required this.text,
    this.color = Colors.blue,
    this.isMobile = false,
    this.isShowIcon = true,
    this.onPressed,
    this.width,
    this.height, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 30 : 16,
            vertical: isMobile ? 14 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isShowIcon) ...[
              Icon(
                icon,
                color: Colors.white,
                size: isMobile ? 16 : 16,
              ),
              const SizedBox(width: 3),
            ],
            Text(
              text,
              style:  TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),

    );

  }
}
