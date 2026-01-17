import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fms_app/screens/admins_screen/apartments_and_rooms.dart';
import 'package:fms_app/screens/admins_screen/settings_screen.dart';
import 'package:fms_app/screens/admins_screen/tenant_screen.dart';
import 'package:fms_app/screens/admins_screen/user_screen.dart';
import 'package:fms_app/screens/dailogs/notication_dailog.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../enums/enum_navigations.dart';
import '../../providers/app_Manager.dart';
import '../../providers/constants.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/siderbar.dart';
import '../dailogs/profile.dart';
import 'dashboard.dart';
import 'artisan_screen.dart';
import 'issue_screen.dart';

class AdminTemplate extends StatefulWidget {
  const AdminTemplate({super.key});

  @override
  State<AdminTemplate> createState() => _AdminTemplateState();
}

class _AdminTemplateState extends State<AdminTemplate> {
  AppNavigation currentPage = AppNavigation.dashboard;
  bool _isLoadingNotifications = false;
  bool _isHoveringProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final response = await ApiService().get('notifications/unread-count', context);

      if (response?.statusCode == 200) {
        final data = jsonDecode(response!.body);
        if (mounted) {
          setState(() {
            unreadCount = data['count'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final horizontalPadding = size.width * 0.015;
    final verticalPadding = size.height * 0.02;

    return ScreenTypeLayout(
      mobile: _mobileLayout(horizontalPadding, verticalPadding),
      tablet: _desktopLayout(horizontalPadding, verticalPadding),
      desktop: _desktopLayout(horizontalPadding, verticalPadding),
    );
  }

  /* ---------------- MOBILE ---------------- */

  Widget _mobileLayout(double hPad, double vPad) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleForPage())),
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
    );
  }

  /* ---------------- DESKTOP / TABLET ---------------- */

  Widget _desktopLayout(double hPad, double vPad) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          Sidebar(
            verticalPadding: vPad,
            selected: currentPage,
            onNavigate: (nav) {
              setState(() => currentPage = nav);
            },
          ),
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dialogBackgroundColor == Colors.grey[850]
                            ? Colors.transparent
                            : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$greeting,",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Here\'s your property overview',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // Notification Bell Icon
                          _buildNotificationBell(),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 40,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),

                          // User Info with Hover
                          MouseRegion(
                            onEnter: (_) => setState(() => _isHoveringProfile = true),
                            onExit: (_) => setState(() => _isHoveringProfile = false),
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: (){
                                ProfileDialog.show(context);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                       Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border:
                                        // _isHoveringProfile
                                        //     ?
                                        Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1,
                                        ),
                                        //    : null,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(
                                          "assets/images/profile.png",
                                          height: vPad * 2.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          capitalizeFirst(AppManager().loginResponse["user"]["first_name"]),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _isHoveringProfile
                                                ? Theme.of(context).primaryColor
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          AppManager().loginResponse["user"]["email"],
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_isHoveringProfile)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context).primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Page Content
                Expanded(child: _pageSwitcher(hPad, vPad, isMobile: false)),
              ],
            ),
          ),
        ],
      ),
    );
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

      case AppNavigation.settings:
        return const SettingsScreen();
    }
  }

  String _titleForPage() {
    switch (currentPage) {
      case AppNavigation.dashboard:
        return 'Dashboard';
      case AppNavigation.apartment:
        return 'Apartment';
      case AppNavigation.artisans:
        return 'Artisans';
      case AppNavigation.compliant:
        return 'Compliant';
      case AppNavigation.tenants:
        return 'Tenants';
      case AppNavigation.users:
        return 'Users';
      case AppNavigation.settings:
        return 'Settings';
    }
  }

  Widget _buildNotificationBell() {
    return InkWell(
      onTap:() async {
        bool? isComplete = await NotificationDialog.show(context, _isLoadingNotifications);
        if(isComplete!){
          _loadUnreadCount();
        }

      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: unreadCount > 0
              ? Colors.orange.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unreadCount > 0
                ? Colors.orange.withOpacity(0.3)
                : Colors.grey.shade300,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              unreadCount > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_outlined,
              color: unreadCount > 0 ? Colors.orange : Colors.grey.shade600,
              size: 22,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}