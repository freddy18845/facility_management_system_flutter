import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogBottomNavigator extends StatelessWidget {
  final Widget  child;
  const DialogBottomNavigator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    return  Container(
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(top: BorderSide(color:Theme.of(context).scaffoldBackgroundColor==Colors.grey.shade50 ?Colors.grey.shade200:Colors.transparent)),
      ),
      child:  child,
    );
  }
}
