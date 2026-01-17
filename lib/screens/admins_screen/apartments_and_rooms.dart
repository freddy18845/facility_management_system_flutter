
import 'package:flutter/material.dart';
import '../../components/apartments_and_rooms/apartment_table.dart';




class ApartmentAndRoomPage extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final bool isMobile;

  const ApartmentAndRoomPage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<ApartmentAndRoomPage> createState() => _ApartmentAndRoomPageState();
}

class _ApartmentAndRoomPageState extends State<ApartmentAndRoomPage>
    with SingleTickerProviderStateMixin {

   
  @override
  void dispose() {
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return  ApartmentTable(
    );
  }

}
