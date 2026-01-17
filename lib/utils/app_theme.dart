import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fms_app/providers/constants.dart';
import 'package:intl/intl.dart';

import '../providers/app_Manager.dart';
import '../screens/login_screen.dart';
import '../screens/dailogs/confirnation_dailog.dart';
import '../widgets/loading.dart';
import 'api_service.dart';
import 'app_theme.dart';

Color getPriorityColor(String? priority) {
  switch (priority?.toUpperCase()) {
    case 'HIGH':
    case 'URGENT':
      return Colors.redAccent;
    case 'MEDIUM':
      return Colors.orangeAccent;
    case 'LOW':
      return Colors.green;
    default:
      return Colors.black;
  }
}
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'in progress':
      return Colors.blue;
    case 'pending':
      return Colors.orange;
    default:
      return Colors.amber;
  }
}
void showCustomSnackBar(
    BuildContext context,
    String message, {
      Color color = Colors.red,
      IconData icon = Icons.info,
    }) {
  final overlay = Overlay.of(context);
  final screenWidth = MediaQuery.of(context).size.width;

  final double toastWidth = screenWidth < 600
      ? screenWidth * 0.8      // 📱 phones
      : 360;                   // 🖥 desktop max width


  final entry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 80,
      left: (screenWidth - toastWidth) / 2,
      width: toastWidth,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 2), entry.remove);
}

String formatHeader(String header) {
  final key = header.toLowerCase().replaceAll(' ', '_');

  if (key == 'is_active') return 'Status';
  if (key == 'created_at') return 'Created Date';
  if (key == 'room_number') return 'Room Label';

  return header;
}
String formatDate(DateTime? date) {
  if (date == null) return 'Not selected';
  return '${date.day}/${date.month}/${date.year}';
}

String apartmentName(int id) {
  for (final apartment in selectedApartmentRoomList) {
    if (apartment['id'] == id) {
      // Convert rooms safely
      selectedRoomList =
      List<Map<String, dynamic>>.from(apartment['rooms'] ?? []);

      return apartment['name'] ?? '';
    }
  }
  return '';
}

String roomName(int id) {
  for (final room in selectedRoomList) {
    if (room['id'] == id) {
      return room['room_number'] ?? '';
    }
  }
  return '';
}
String formatForLaravel(DateTime date) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
}
final ValueNotifier<Map<String, String?>> errors =
ValueNotifier({});
void setError(String key, String? message) {
  final current = Map<String, String?>.from(errors.value);
  if (message == null) {
    current.remove(key);
  } else {
    current[key] = message;
  }
  errors.value = current;
}

String? required(String value, String field) {
  if (value.trim().isEmpty) {
    return '$field is required';
  }
  return null;
}

String? emailValidator(String value) {
  if (value.isEmpty) return 'Email is required';
  if (!value.contains('@')) return 'Invalid email format';
  return null;
}

DateTime? parseDate(dynamic dateValue) {
  if (dateValue == null) return null;

  try {
    if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else if (dateValue is DateTime) {
      return dateValue;
    }
  } catch (e) {
    debugPrint('❌ Error parsing date: $e');
  }

  return null;
}

String capitalizeFirst(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}