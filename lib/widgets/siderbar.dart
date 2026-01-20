import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fms_app/providers/app_Manager.dart';
import 'package:fms_app/widgets/settings_card.dart';

import '../Models/company_data.dart';
import '../enums/enum_navigations.dart';
import '../screens/login_screen.dart';
import '../screens/dailogs/confirnation_dailog.dart';
import '../utils/api_service.dart';
import '../utils/app_theme.dart';
import 'btn.dart';
import 'loading.dart';

class Sidebar extends StatefulWidget {
  final double verticalPadding;
  final AppNavigation selected;
  final Function(AppNavigation) onNavigate;

  const Sidebar({
    super.key,
    required this.selected,
    required this.onNavigate,
    required this.verticalPadding,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _base64Logo;
  @override
  void initState() {
    super.initState();
    _loadLogo();
  }

  /// 🔴 LOGOUT FUNCTION
  Future<void> logout(BuildContext context) async {
    LoadingScreen.show(context, message: 'Logging out...');

    try {
      await Future.delayed(const Duration(seconds: 1));

      final response = await ApiService().post(
        'auth/logout',
        {},
        context,
        true,
      );

      if (mounted) LoadingScreen.hide(context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        final responseData = jsonDecode(response!.body);
        debugPrint('📦 Logout response: $responseData');

        // Clear AppManager data
        await AppManager().clearLoginData();

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

  // Fetch company logo
  Future<void> _loadLogo() async {
    final companyJson = AppManager().loginResponse["user"]["company"];
    final String? rawPath =
        companyJson?['logo']; // This is "logos/filename.jpg"

    if (rawPath != null) {
      try {
        // Use your existing ApiService to call the new proxy route
        final response = await ApiService().get(
          'company-logo-proxy?path=$rawPath',context,
        );
        if (response != null && response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _base64Logo =
                data['data']; // The full data:image/jpeg;base64... string
          });
        }
      } catch (e) {
        debugPrint('❌ Proxy Load Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyJson = AppManager().loginResponse["user"]["company"];
    final Company? companyData = companyJson != null
        ? Company.fromJson(Map<String, dynamic>.from(companyJson))
        : null;

    // 👇 Wrap the logoUrl with our new formatter
    final logoUrl = formatImageUrl(companyData?.logoUrl);

    debugPrint('🖼️ Formatted Logo URL: $logoUrl');

    debugPrint('🏢 Company: ${companyData?.name}');
    debugPrint('🖼️ Logo URL to load: $logoUrl');

    return Container(
      width: 220,
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(
        children: [
          SizedBox(height: widget.verticalPadding),
          _buildLogo(logoUrl, companyData?.name),
          // Container(
          //   padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
          //   child: ,
          // ),
          const Divider(thickness: 0.5),
          _menuItem(
            Icons.dashboard_outlined,
            'Dashboard',
            AppNavigation.dashboard,
          ),
          _menuItem(
            Icons.apartment_rounded,
            'Apartments',
            AppNavigation.apartment,
          ),
          _menuItem(
            Icons.report_gmailerrorred,
            'Compliant',
            AppNavigation.compliant,
          ),
          _menuItem(
            Icons.engineering_outlined,
            'Artisans',
            AppNavigation.artisans,
          ),
          _menuItem(Icons.apartment_outlined, 'Tenants', AppNavigation.tenants),
          _menuItem(Icons.group_outlined, 'Users', AppNavigation.users),
          _menuItem(Icons.group_outlined, 'Transactions', AppNavigation.transactions),
          _menuItem(
            Icons.settings_outlined,
            'Settings',
            AppNavigation.settings,
          ),
          const Spacer(),

          buildSection(
            title: 'About',
            icon: Icons.info,
            color: Colors.grey,
            context: context,
            children: [
              buildListTile(
                icon: Icons.chat,
                title: 'Contact Support',
                subtitle: 'Chat with our support team',
                onTap: () {},
              ),
              buildListTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: 'v1.0.0',
              ),
            ],
          ),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: widget.verticalPadding,
              horizontal: 8,
            ),
            child: CustomButton(
              icon: Icons.logout_outlined,
              text: 'Logout',
              color: Colors.red,
              onPressed: () async {
                bool? confirmed = await ConfirmationDialog.show(
                  context,
                  title: 'Logout',
                  message: 'Are you sure you want to logout?',
                );

                if (confirmed == true) {
                  await logout(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(String? logoUrl, String? companyName) {
    // Check if logo URL is valid
    if (_base64Logo != null) {
      // We strip the prefix "data:image/jpeg;base64," to get the raw bytes
      final String base64String = _base64Logo!.split(',').last;

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          base64Decode(base64String),
          height: 80,
        ),
      );
    }
    // If no logo URL, show company name
    return _buildCompanyNameFallback(companyName);
  }

  Widget _buildCompanyNameFallback(String? companyName) {
    return Container(
      width: 200,
      height: 90,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          companyName ?? 'Company',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, AppNavigation nav) {
    final isActive = widget.selected == nav;

    return Container(
      color: isActive ? Colors.grey.withOpacity(0.3) : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.black : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => widget.onNavigate(nav),
      ),
    );
  }
}

String formatImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  // If running on Android Emulator, 127.0.0.1 must be 10.0.2.2
  // If running on iOS Simulator or Web, 127.0.0.1 is usually fine
  // If running on a Physical Device, you must use your Mac's Local IP (e.g. 192.168.1.x)

  if (url.contains('127.0.0.1')) {
    // For Android Emulator:
    return url.replaceAll('127.0.0.1', '10.0.2.2');
  }
  return url;
}
