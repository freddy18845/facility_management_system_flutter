// Shimmer Loading States
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildShimmerHeader() {
  return Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

Widget buildShimmerCards({required double horizontalPadding, required double verticalPadding , required bool isMobile}) {
  return Wrap(
    spacing: horizontalPadding,
    runSpacing: verticalPadding,
    children: List.generate(
      4,
          (index) => Container(
        width: isMobile ? double.infinity : 280,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}

Widget buildShimmerChart() {
  return Container(
    height: 200,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}