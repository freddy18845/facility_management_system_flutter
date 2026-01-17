import 'dart:convert';
import 'package:flutter/material.dart';

import '../../providers/app_Manager.dart';
import '../../providers/constants.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
class NotificationDialog extends StatefulWidget {
 final bool? isHoveringProfile;
  const NotificationDialog({super.key,

    this.isHoveringProfile=false,});

 static Future<bool?> show(BuildContext context,bool? isHoveringProfile) {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>  NotificationDialog(
          isHoveringProfile: isHoveringProfile,),
    );
  }

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> notificationsList =[];
  bool isLoadingNotifications = false;
  final user = AppManager().loginResponse["user"];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
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

  // Load all notifications
  Future<void> _loadNotifications() async {
    setState(() {
      isLoadingNotifications = true;
    });

    try {
      final response = await ApiService().get('notifications', context);

      if (response?.statusCode == 200) {
        final data = jsonDecode(response!.body);
        setState(() {
          notificationsList = List<Map<String, dynamic>>.from(
            data['data']['data'] ?? [],
          );
          unreadCount = data['unread_count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) {
        showCustomSnackBar(context, 'Failed to load notifications', color: Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingNotifications = false;
        });
      }
    }
  }

  // Mark notification as read
  Future<void> _markAsRead(String notificationId) async {
    try {
      await ApiService().post(
        'notifications/$notificationId/read',
        {},
        context,
        true,
      );

      // Reload notifications and count
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  // Mark all as read
  Future<void> _markAllAsRead() async {
    try {
      await ApiService().post(
        'notifications/mark-all-read',
        {},
        context,
        true,
      );

      setState(() {
        unreadCount = 0;
      });

      await _loadNotifications();

      if (mounted) {
        showCustomSnackBar(
          context,
          'All notifications marked as read',
          color: Colors.green,
        );
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
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
        width: 500,
        height: 600,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Image
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (unreadCount > 0)
                        TextButton.icon(
                          onPressed: _markAllAsRead,
                          icon: const Icon(Icons.done_all, size: 16),
                          label: const Text('Mark all read'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop(true);
                          }
                        },
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ],
              ),
            ),


            Expanded(
              child:
              isLoadingNotifications
                  ? const Center(child: CircularProgressIndicator())
                  :
             notificationsList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notificationsList.length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(
                    notificationsList[index],
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['read_at'] != null;
    final data = notification['data'] as Map<String, dynamic>;
    final type = data['type'] ?? '';

    Color iconColor = Colors.blue;
    IconData icon = Icons.info_rounded;

    if (type == 'overdue') {
      iconColor = Colors.red;
      icon = Icons.warning_rounded;
    } else if (type == 'assigned') {
      iconColor = Colors.green;
      icon = Icons.assignment_ind_rounded;
    }

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? Colors.grey.shade200 : Colors.blue.shade200,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (!isRead) {
              _markAsRead(notification['id']);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['message'] ?? 'Notification',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (data['tenant_name'] != null)
                        Text(
                          'Reported by: ${data['tenant_name']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      if (data['priority'] != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getPriorityColor(data['priority'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            data['priority'].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: getPriorityColor(data['priority']),
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        formatTime(notification['created_at']),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _deleteNotification(String notificationId) async {
    try {
      await ApiService().delete(
        'notifications/$notificationId',
        context,
        true,
      );

      await _loadNotifications();

      if (mounted) {
        showCustomSnackBar(
          context,
          'Notification deleted',
          color: Colors.orange,
        );
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  String formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${(difference.inDays / 7).floor()}w ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}

