import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import '../../widgets/btn.dart';

class RoomDialog extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isOnlyCancel;

  const RoomDialog({
    super.key,
    required this.title,
    required this.child,
    required this.isOnlyCancel,
  });

  /// Shows dialog and returns bool?
  /// true  → Submit
  /// false → Cancel / Close
  /// null  → dismissed
  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required Widget child,
        required bool isOnlyCancel,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RoomDialog(
        title: title,
        child: child,
        isOnlyCancel: isOnlyCancel,
      ),
    );
  }

  @override
  State<RoomDialog> createState() => _RoomDialogState();
}

class _RoomDialogState extends State<RoomDialog> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
         DialogHeader(title:  widget.title,),

            /// BODY
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),

            /// FOOTER
            DialogBottomNavigator(child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  text: 'Cancel',
                  color: Colors.red,
                  isShowIcon: false,
                  onPressed: () => Navigator.pop(context, false), icon: Icons.insert_emoticon_sharp,
                ),
                if (!widget.isOnlyCancel)
                  CustomButton(
                    text: 'Submit',
                    color: Colors.green,
                    isShowIcon: false,
                    icon: Icons.insert_emoticon_sharp,
                    onPressed: () => Navigator.pop(context, true),
                  ),
              ],
            ))


          ],
        ),
      ),
    );
  }

}
