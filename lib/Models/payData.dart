import 'package:flutter/cupertino.dart';

Map<String, dynamic> payData(
    String label,
    String price,
    double amt,
    int qty,
    String type,
    IconData icon,
    Color bgColor,
    ) {
  return {
    'label': label,
    'price': price,
    'amt': amt,
    'qty': qty,
    'type': type,
    'icon': icon,
    'bgColor': bgColor,
  };
}