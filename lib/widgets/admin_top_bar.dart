import 'package:flutter/material.dart';
import '../providers/app_Manager.dart';
import '../screens/admins_screen/app_temple.dart';
import '../utils/app_theme.dart';
import '../screens/dailogs/profile.dart';
import 'notification_bell.dart';
class AdminTopBar extends StatelessWidget {
  final double horizontalPadding;
  final VoidCallback onNotificationRefresh;

  const AdminTopBar({
    super.key,
    required this.horizontalPadding,
    required this.onNotificationRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
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
                Text("$greeting,", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 2),
                Text('Here\'s your property overview', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.9))),
              ],
            ),
          ),
          Row(
            children: [
              NotificationBell(onRefresh: onNotificationRefresh),

              // Wrap the divider in a SizedBox with a height
              SizedBox(
                height: 65, // Adjust this height to match your top bar
                child:  VerticalDivider(
                  width: 20,
                  thickness: 1.5, // 5 is very thick, 1 or 2 usually looks better
                  indent: 10,
                  endIndent: 10,
                  color: Colors.grey.shade300,
                ),
              ),

              _buildUserProfile(context),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return GestureDetector(
      onTap: () => ProfileDialog.show(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset("assets/images/profile.png", height: 35),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  capitalizeFirst(AppManager().loginResponse["user"]["first_name"]),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                Text(
                  AppManager().loginResponse["user"]["email"],
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}