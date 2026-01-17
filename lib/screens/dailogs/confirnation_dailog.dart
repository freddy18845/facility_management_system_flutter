import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/loading.dart';
import '../../widgets/textform.dart';
import '../login_screen.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;

  const ConfirmationDialog({super.key, required this.title, required this.message});

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();

  /// Shows the dialog and returns a Future<bool?>.
  static Future<bool?> show(BuildContext context,
      {required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(title: title, message: message),
    );
  }
}

class _ConfirmationDialogState extends State<ConfirmationDialog>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 28),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
DialogBottomNavigator(child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    CustomButton(
      text: 'No',
      icon: Icons.close,
      color: Colors.red,
      onPressed: () => Navigator.pop(context, false), // Return false
      isShowIcon: false,
    ),
    CustomButton(
      text: 'Yes',
      icon: Icons.check,
      color: Colors.green,
      onPressed: () => Navigator.pop(context, true), // Return true
      isShowIcon: false,
    ),
  ],
))
            // Navigation Buttons

          ],
        ),
      ),
    );
  }
}
