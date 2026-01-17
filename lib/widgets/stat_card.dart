import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isMobile;

  const StatCard({super.key, required this.title,
    required this.value,
    required  this.icon,
    this.isMobile =false

  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width:isMobile?screenWidth * 0.47: screenWidth * 0.151,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 0.8, color: Theme.of(context).cardColor==Colors.white? Colors.grey.shade200:Colors.transparent)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
         children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:Colors.blue.withValues(alpha: 0.25) ,
              borderRadius: BorderRadius.circular(10)
            ),
            child:  Icon(icon, color: Colors.blue,),
          ) ,
           SizedBox(width: 5,),
           Text(title,
               style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
         ],
         ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
