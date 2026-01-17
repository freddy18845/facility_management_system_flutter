import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Models/company_data.dart';
import '../providers/app_Manager.dart';
import '../screens/dailogs/profile.dart';
import '../screens/login_screen.dart';
import '../screens/dailogs/confirnation_dailog.dart';
import '../utils/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/btn.dart';
import '../widgets/loading.dart';
import '../widgets/profile_widget.dart';

class Navbar extends StatefulWidget {
  final bool isMobile;
  const Navbar({super.key, required this.isMobile});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  Future<void> logout(BuildContext context) async {
    LoadingScreen.show(context, message: 'Logging out...');

    try {
      await Future.delayed(const Duration(seconds: 1));

      final response = await ApiService().post(
        'auth/logout', // ✅ correct endpoint
        {}, // ✅ empty body
        context,
        true, // ✅ MUST be true (send token)
      );

      if (mounted) LoadingScreen.hide(context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        final responseData = jsonDecode(response!.body);
        debugPrint('📦 Logout response: $responseData');

        // ✅ Clear stored auth data
        // await AppManager().logout();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      } else {
        throw Exception('Logout failed');
      }
    } catch (e, stackTrace) {
      if (mounted) LoadingScreen.hide(context);

      debugPrint('❌ Logout error: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      if (mounted) {
        showCustomSnackBar(
          context,
          'Logout failed. Please try again.',
          color: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    final companyJson = AppManager().loginResponse["user"]["company"];
    final Company? companyData = companyJson != null
        ? Company.fromJson(Map<String, dynamic>.from(companyJson))
        : null;
    return Container(
      color: const Color(0xFF302f2f),
      padding: const EdgeInsets.all(12),
      child: widget.isMobile
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                InkWell(
                  onTap: (){
                    ProfileDialog.show(context);
                  },
                  child:  Container(

                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/images/profile.png',
                            height: 28,
                            width: 28,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$greeting, \n${capitalizeFirst(
                            AppManager().loginResponse["user"]["first_name"],
                          )}',
                          style: TextStyle(fontSize: 9, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                        companyData?.name ?? 'Company',
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                CustomButton(
                  icon: Icons.login_outlined,
                  text: '',
                  color: Colors.red,
                  onPressed: () async {
                    bool? confirmed = await ConfirmationDialog.show(
                      context,
                      title: 'Logout',
                      message: 'Are you sure you want to logout?',
                    );

                    if (confirmed == true) {
                     logout(context);
                    }
                  },
                ),
              ],
            )
          : Row(
              children: [

                Text(
                  companyData?.name ?? 'Company',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                ProfileWidget(),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                CustomButton(
                  icon: Icons.login_outlined,
                  text: 'Logout',
                  color: Colors.red,
                  onPressed: () async {
                    bool? confirmed = await ConfirmationDialog.show(
                      context,
                      title: 'Logout',
                      message: 'Are you sure you want to logout?',
                    );

                    if (confirmed == true) {
                      logout(context);
                    }
                  },
                ),
              ],
            ),
    );
  }
}
