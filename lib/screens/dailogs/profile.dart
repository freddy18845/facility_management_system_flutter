import 'dart:convert';
import 'package:flutter/material.dart';

import '../../providers/app_Manager.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading.dart';
import '../login_screen.dart';
import 'confirnation_dailog.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProfileDialog(),
    );
  }

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final user = AppManager().loginResponse["user"];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext parentContext) async {
    try {
      LoadingScreen.show(parentContext, message: 'Logging out...');
      debugPrint('✅ [LOGOUT] Loading screen shown');
    } catch (e) {
      debugPrint('❌ [LOGOUT] Failed to show loading screen: $e');
      return;
    }

    try {
      debugPrint('🔵 [LOGOUT] Step 6: Waiting 1 second delay');
      await Future.delayed(const Duration(seconds: 1));

      debugPrint('🔵 [LOGOUT] Step 7: Making API logout call');
      final response = await ApiService().post(
        'auth/logout',
        {},
        parentContext,
        true,
      );

      debugPrint('🔵 [LOGOUT] Step 8: API response received - Status: ${response?.statusCode}');

      // Always hide loading first
      debugPrint('🔵 [LOGOUT] Step 9: Hiding loading screen');
      LoadingScreen.hide(parentContext);
      debugPrint('✅ [LOGOUT] Loading screen hidden');

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        debugPrint('✅ [LOGOUT] Step 10: Logout successful');
        final responseData = jsonDecode(response!.body);
        debugPrint('📦 [LOGOUT] Response data: $responseData');

        debugPrint('🔵 [LOGOUT] Step 11: Clearing AppManager data');
        await AppManager().clearLoginData();
        debugPrint('✅ [LOGOUT] AppManager data cleared');

        debugPrint('🔵 [LOGOUT] Step 12: Navigating to login screen');
        Navigator.pushAndRemoveUntil(
          parentContext,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
        );
        debugPrint('✅ [LOGOUT] Navigation complete');
      } else {
        debugPrint('🔴 [LOGOUT] Unexpected status code: ${response?.statusCode}');
        throw Exception('Logout failed with status: ${response?.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [LOGOUT] ERROR in logout process');
      debugPrint('❌ [LOGOUT] Error: $e');
      debugPrint('❌ [LOGOUT] Stack trace: $stackTrace');

      debugPrint('🔵 [LOGOUT] Attempting to hide loading screen after error');
      try {
        LoadingScreen.hide(parentContext);
        debugPrint('✅ [LOGOUT] Loading screen hidden after error');
      } catch (hideError) {
        debugPrint('❌ [LOGOUT] Failed to hide loading screen: $hideError');
      }

      debugPrint('🔵 [LOGOUT] Showing error message to user');
      try {
        showCustomSnackBar(
          parentContext,
          'Logout failed. Please try again.',
          color: Colors.red,
        );
        debugPrint('✅ [LOGOUT] Error message shown');
      } catch (snackBarError) {
        debugPrint('❌ [LOGOUT] Failed to show error message: $snackBarError');
      }
    }

    debugPrint('🔵 [LOGOUT] Logout process completed');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  "assets/images/profile.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey.shade400,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              "${capitalizeFirst(user["first_name"])} ${capitalizeFirst(user["last_name"] ?? '')}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                capitalizeFirst(user["role"] ?? "User"),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Email
            _buildProfileInfoRow(
              Icons.email_outlined,
              'Email',
              user["email"] ?? 'N/A',
            ),
            const SizedBox(height: 12),

            // Phone
            _buildProfileInfoRow(
              Icons.phone_outlined,
              'Phone',
              user["contact"] ?? 'N/A',
            ),
            const SizedBox(height: 12),

            // Location (if available)
            if (user["location"] != null)
              _buildProfileInfoRow(
                Icons.location_on_outlined,
                'Location',
                user["location"],
              ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:(){
                      _handleLogout(context);
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Standalone helper widget for profile info row
Widget _buildProfileInfoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ],
  );
}