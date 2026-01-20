import 'package:flutter/material.dart';
import '../providers/constants.dart';
import '../screens/dailogs/notication_dailog.dart';

class NotificationBell extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool isLoading;

  const NotificationBell({
    super.key,
    required this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Now 'context' is available from the build method
        bool? isComplete = await NotificationDialog.show(context, isLoading);
        if (isComplete == true) {
          onRefresh(); // Calls _loadUnreadCount in the parent
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