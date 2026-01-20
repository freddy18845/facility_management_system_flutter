import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/loading.dart';
import '../../widgets/textform.dart';

class ResetOrForgottenPasswordDialog extends StatefulWidget {
  ResetOrForgottenPasswordDialog({super.key});

  @override
  State<ResetOrForgottenPasswordDialog> createState() =>
      _ResetOrForgottenPasswordDialogState();

  /// Shows the dialog and returns a Future<bool?>.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResetOrForgottenPasswordDialog(),
    );
  }
}

class _ResetOrForgottenPasswordDialogState
    extends State<ResetOrForgottenPasswordDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
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
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 28),
                  Text(
                    'Password',
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
            SizedBox(height: 16,),
            Text(
              'Enter your email address',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.normal,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Expanded(
                child: buildField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),

            DialogBottomNavigator(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: ' Cancel',
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () => Navigator.pop(context), // Return false
                    isShowIcon: false,
                  ),
                  CustomButton(
                    text: 'Submit',
                    icon: Icons.check,
                    color: Colors.green,
                    onPressed: () async {
                      LoadingScreen.show(context, message: 'Loading...');
                      try {
                        final response = await ApiService().post(
                          'forgot-password',
                          {'email': _emailController.text.toLowerCase()},
                          context,
                          false,
                        );

                        if (mounted) LoadingScreen.hide(context);

                        if (response?.statusCode == 200 ||
                            response?.statusCode == 201) {
                          final responseData = jsonDecode(response!.body);

                          debugPrint('📦 Response data: $responseData');

                          // Save login data
                          if (mounted) {
                            showCustomSnackBar(
                              context,
                              responseData['message'],
                              color: Colors.green,
                            );

                            // Get role using the getter method
                          } else {
                            final errorData = jsonDecode(response.body);
                            if (mounted) {
                              showCustomSnackBar(
                                context,
                                errorData['message'] ?? 'Login failed',
                                color: Colors.red,
                              );
                            }
                          }
                          if (mounted) Navigator.pop(context);
                        }
                      } catch (e, stackTrace) {
                        if (mounted) LoadingScreen.hide(context);
                        debugPrint('❌ Login error: $e');
                        if (mounted) {
                          showCustomSnackBar(
                            context,
                            'Login failed. Please try again.',
                            color: Colors.red,
                          );
                        }
                        if (mounted) Navigator.pop(context);
                        // Return true
                      }
                    },
                  ),
                ],
              ),
            ),

            // Navigation Buttons
          ],
        ),
      ),
    );
  }
}
