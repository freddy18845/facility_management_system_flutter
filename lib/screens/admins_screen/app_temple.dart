import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Import your custom widgets
import '../../providers/app_Manager.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/siderbar.dart';
import '../../widgets/admin_top_bar.dart';
// Import your screens
import '../login_screen.dart';
import 'dashboard.dart';
import 'artisan_screen.dart';
import 'issue_screen.dart';
import 'apartments_and_rooms.dart';
import 'settings_screen.dart';
import 'tenant_screen.dart';
import 'transactions_screen.dart';
import 'user_screen.dart';

// Import providers/utils
import '../../enums/enum_navigations.dart';
import '../../providers/constants.dart';
import '../../utils/api_service.dart';

class AdminTemplate extends StatefulWidget {
  const AdminTemplate({super.key});

  @override
  State<AdminTemplate> createState() => _AdminTemplateState();
}

class _AdminTemplateState extends State<AdminTemplate> {
  AppNavigation currentPage = AppNavigation.dashboard;
  Timer? _notificationTimer;
  Timer? _inactivityTimer;
// Set timeout duration (e.g., 15 minutes)
  static final _timeoutDuration = Duration(minutes: ideaTimeDuration);

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    // Polls the server for new notifications every 60 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 60), (t) => _loadUnreadCount());
  }

  Future<void> _handleAutoLogout() async {
    if (!mounted) return;
    LoadingScreen.show(context, message: 'Logging out...');

    try {

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

  void _startInactivityTimer() {
    _inactivityTimer?.cancel(); // Cancel any existing timer
    _inactivityTimer = Timer(_timeoutDuration, _handleAutoLogout);
  }


  @override
  void dispose() {
    _notificationTimer?.cancel(); // Prevents memory leaks
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    if (!mounted) return;
    try {
      final response = await ApiService().get('notifications/unread-count', context);
      if (response?.statusCode == 200) {
        final data = jsonDecode(response!.body);
        if (mounted) {
          setState(() => unreadCount = data['count'] ?? 0);
        }
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.015;
    final vPad = size.height * 0.02;

    return Listener(
        onPointerDown: (_) => _startInactivityTimer(), // Reset timer on every touch
        child :ScreenTypeLayout(
      mobile: Scaffold(
        appBar: AppBar(
          title: Text(_titleForPage()),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: NotificationBell(onRefresh: _loadUnreadCount),
            )
          ],
        ),
        drawer: Drawer(
          child: Sidebar(
            verticalPadding: vPad,
            selected: currentPage,
            onNavigate: (nav) {
              setState(() => currentPage = nav);
              Navigator.pop(context);
            },
          ),
        ),
        body: _pageSwitcher(hPad, vPad, isMobile: true),
      ),
      desktop: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            Sidebar(
              verticalPadding: vPad,
              selected: currentPage,
              onNavigate: (nav) => setState(() => currentPage = nav),
            ),
            Expanded(
              child: Column(
                children: [
                  AdminTopBar(
                    horizontalPadding: hPad,
                    onNotificationRefresh: _loadUnreadCount,
                  ),
                  Expanded(
                    child: _pageSwitcher(hPad, vPad, isMobile: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  /* ---------------- PAGE SWITCHER ---------------- */

  Widget _pageSwitcher(double hPad, double vPad, {required bool isMobile}) {
    switch (currentPage) {
      case AppNavigation.dashboard:
        return DashboardContent(
          horizontalPadding: hPad,
          verticalPadding: vPad,
          isMobile: isMobile,
        );
      case AppNavigation.apartment:
        return ApartmentAndRoomPage(
          horizontalPadding: hPad,
          verticalPadding: vPad,
          isMobile: isMobile,
        );
      case AppNavigation.artisans:
        return ArtisanPage(
          horizontalPadding: hPad,
          verticalPadding: vPad,
          isMobile: isMobile,
        );
      case AppNavigation.compliant:
        return const IncidentsScreen();
      case AppNavigation.tenants:
        return TenantPage(
          horizontalPadding: hPad,
          verticalPadding: vPad,
          isMobile: isMobile,
        );
      case AppNavigation.users:
        return UsersPage(
          horizontalPadding: hPad,
          verticalPadding: vPad,
          isMobile: isMobile,
        );
      case AppNavigation.transactions:
        return TransactionsPage(
          horizontalPadding: hPad,
          verticalPadding: vPad,
          isMobile: isMobile,
        );
      case AppNavigation.settings:
        return const SettingsScreen();
      default:
        return const Center(child: Text("Page Not Found"));
    }
  }

  /* ---------------- TITLE GENERATOR ---------------- */

  String _titleForPage() {
    switch (currentPage) {
      case AppNavigation.dashboard: return 'Dashboard';
      case AppNavigation.apartment: return 'Apartments';
      case AppNavigation.artisans: return 'Artisans';
      case AppNavigation.compliant: return 'Complaints';
      case AppNavigation.tenants: return 'Tenants';
      case AppNavigation.users: return 'Users';
      case AppNavigation.transactions: return 'Transactions';
      case AppNavigation.settings: return 'Settings';
      default: return 'FMS Admin';
    }
  }
}