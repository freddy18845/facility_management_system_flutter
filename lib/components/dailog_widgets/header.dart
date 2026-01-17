import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogHeader extends StatelessWidget {
  final String title;
  const DialogHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;
    return  Container(
      padding: EdgeInsets.symmetric(horizontal:horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),

        border: Border(top: BorderSide(color:Theme.of(context).scaffoldBackgroundColor==Colors.grey.shade50 ?Colors.grey.shade200:Colors.transparent),
        ),
      ),child:  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 24),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: (){
             Navigator.of(context).pop();
          },
        ),
      ],
    ),
    );
  }
}
