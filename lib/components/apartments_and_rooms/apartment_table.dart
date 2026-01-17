// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fms_app/components/selectedRoomlist.dart';
// import '../providers/app_Manager.dart';
// import '../providers/constants.dart';
// import '../screens/dailogs/room.dart';
// import '../utils/api_service.dart';
// import '../utils/app_theme.dart';
// import '../widgets/btn.dart';
// import '../widgets/custom_table.dart';
// import '../widgets/loading.dart';
// import '../widgets/textform.dart';
//
// class ApartmentTable extends StatefulWidget {
//   const ApartmentTable({super.key});
//
//   @override
//   State<ApartmentTable> createState() => _ApartmentTableState();
// }
//
// class _ApartmentTableState extends State<ApartmentTable> {
//   final TextEditingController addNewApartmentController = TextEditingController();
//   final TextEditingController addNewRoomController = TextEditingController();
//
//   List<Map<String, dynamic>> apartments = [];
//   List<Map<String, dynamic>> roomList = [];
//   String _selectedRoomId = '1';
//
//   /// Holds the currently selected apartment
//   Map<String, dynamic> activeApartment = {};
//
//   @override
//   void initState() {
//     super.initState();
//     loadApartmentData();
//   }
//
//   @override
//   void dispose() {
//     addNewApartmentController.dispose();
//     addNewRoomController.dispose();
//     super.dispose();
//   }
//
//   // ================= LOAD ALL APARTMENTS =================
//   Future<void> loadApartmentData() async {
//     try {
//       int? companyId = AppManager().loginResponse["user"]["company_id"];
//
//       if (companyId == null) {
//         showCustomSnackBar(context, 'Company ID not found');
//         return;
//       }
//
//       final response = await ApiService().get('apartments/$companyId', context);
//
//       if (response?.statusCode == 200 || response?.statusCode == 201) {
//         final responseData = jsonDecode(response!.body);
//
//         setState(() {
//           apartments = List<Map<String, dynamic>>.from(responseData["data"]);
//
//           // Set first apartment as active by default (if exists)
//           if (apartments.isNotEmpty) {
//             activeApartment = apartments.first;
//           //  loadSelectedApartmentRoom(activeApartment["rooms"]);
//           }
//         });
//       } else {
//         final responseData = jsonDecode(response!.body);
//         showCustomSnackBar(context, responseData["message"]);
//       }
//     } catch (e) {
//       debugPrint('❌ API error: $e');
//       if (mounted) {
//         showCustomSnackBar(context, 'Network Error');
//       }
//     }
//   }
//
//   // ================= LOAD APARTMENT BY ID =================
//   Future<void> loadSelectedApartmentRoom(Map<String, dynamic> selectedApartment) async {
//     try {
//
//       if (selectedApartment["rooms"] !=[]) {
//
//         setState(() {
//           activeApartment = selectedApartment;
//           roomList = List<Map<String, dynamic>>.from(
//             activeApartment["rooms"] ?? [],
//           );
//         });
//       } else {
//         showCustomSnackBar(context, 'Sorry, selected apartment has no rooms');
//       }
//     } catch (e) {
//       debugPrint('❌ API error: $e');
//       if (mounted) {
//         showCustomSnackBar(context, 'Network Error');
//       }
//     }
//   }
//
//   // ================= ADD NEW APARTMENT =================
//   Future<void> addNewApartment() async {
//     if (addNewApartmentController.text.trim().isEmpty) {
//       showCustomSnackBar(
//         context,
//         "You cannot add an empty apartment",
//         color: Colors.orange,
//       );
//       return;
//     }
//
//     int? companyId = AppManager().loginResponse["user"]["company_id"];
//
//     if (companyId == null) {
//       showCustomSnackBar(context, 'Company ID not found');
//       return;
//     }
//
//     LoadingScreen.show(context, message: 'Adding apartment...');
//
//     try {
//       final response = await ApiService().post(
//         'apartments',
//         {
//           'name': addNewApartmentController.text.trim(),
//           'company_id': companyId,
//         },
//         context,
//         true,
//       );
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//       }
//
//       if (response?.statusCode == 200 || response?.statusCode == 201) {
//         addNewApartmentController.clear();
//         await loadApartmentData();
//
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             "Apartment added successfully!",
//             color: Colors.green,
//           );
//         }
//       } else {
//         final errorData = jsonDecode(response!.body);
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             errorData['message'] ?? 'Failed to add apartment',
//             color: Colors.red,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(context, e.toString(), color: Colors.red);
//       }
//     }
//   }
//
//   // ================= UPDATE APARTMENT =================
//   Future<void> updateApartment() async {
//     if (activeApartment.isEmpty) {
//       showCustomSnackBar(
//         context,
//         "Please select an apartment first",
//         color: Colors.orange,
//       );
//       return;
//     }
//
//     setState(() {
//       addNewApartmentController.text = activeApartment["name"];
//     });
//
//     final bool? result = await RoomDialog.show(
//       context,
//       title: 'Update Apartment',
//       isOnlyCancel: false,
//       child: SizedBox(
//         width: 350,
//         child: buildField(
//           controller: addNewApartmentController,
//           label: 'Apartment name',
//           icon: Icons.apartment,
//         ),
//       ),
//     );
//
//     if (result != true) return;
//
//     LoadingScreen.show(context, message: 'Updating apartment...');
//
//     try {
//       final response = await ApiService().put(
//         'apartments/${activeApartment["id"]}',
//         {'name': addNewApartmentController.text.trim()},
//         context,
//         true,
//       );
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//       }
//
//       if (response?.statusCode == 200) {
//         addNewApartmentController.clear();
//         await loadApartmentData();
//
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             "Apartment updated successfully!",
//             color: Colors.green,
//           );
//         }
//       } else {
//         final errorData = jsonDecode(response!.body);
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             errorData['message'] ?? 'Failed to update apartment',
//             color: Colors.red,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(context, e.toString(), color: Colors.red);
//       }
//     }
//   }
//
//   // ================= DELETE APARTMENT =================
//   Future<void> deleteApartment(int apartmentId) async {
//     final bool? confirm = await RoomDialog.show(
//       context,
//       title: 'Delete Apartment',
//       isOnlyCancel: false,
//       child: const Text(
//         'Are you sure you want to delete this apartment? This action cannot be undone.',
//       ),
//     );
//
//     if (confirm != true) return;
//
//     LoadingScreen.show(context, message: 'Deleting apartment...');
//
//     try {
//       final response = await ApiService().delete(
//         'apartments/$apartmentId',
//         context,
//         true,
//       );
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//       }
//
//       if (response?.statusCode == 200) {
//         await loadApartmentData();
//
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             "Apartment deleted successfully!",
//             color: Colors.green,
//           );
//         }
//       } else {
//         final errorData = jsonDecode(response!.body);
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             errorData['message'] ?? 'Failed to delete apartment',
//             color: Colors.red,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(context, e.toString(), color: Colors.red);
//       }
//     }
//   }
//
//   // ================= ADD NEW ROOM =================
//   Future<void> addNewRoom() async {
//     if (addNewRoomController.text.trim().isEmpty) {
//       showCustomSnackBar(
//         context,
//         "Room number cannot be empty",
//         color: Colors.orange,
//       );
//       return;
//     }
//
//     if (activeApartment.isEmpty || apartments.isEmpty) {
//       showCustomSnackBar(
//         context,
//         "Select or create an apartment first",
//         color: Colors.orange,
//       );
//       return;
//     }
//
//     LoadingScreen.show(context, message: 'Adding room...');
//
//     try {
//       final response = await ApiService().post(
//         'rooms',
//         {
//           'apartment_id': activeApartment["id"],
//           'room_number': addNewRoomController.text.trim(),
//           'is_active': 1, // Active by default
//         },
//         context,
//         true,
//       );
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//       }
//
//       if (response?.statusCode == 200 || response?.statusCode == 201) {
//         addNewRoomController.clear();
//       //  await loadSelectedApartmentRoom(activeApartment["id"]);
//
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             "Room added successfully!",
//             color: Colors.green,
//           );
//         }
//       } else {
//         final errorData = jsonDecode(response!.body);
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             errorData['message'] ?? 'Failed to add room',
//             color: Colors.red,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(context, e.toString(), color: Colors.red);
//       }
//     }
//   }
//
//   // ================= UPDATE ROOM =================
//   Future<void> updateRoom(Map<String, dynamic> room) async {
//     final roomNumberController = TextEditingController(
//       text: room['room_number'],
//     );
//
//     String localStatus = room['is_active'] == 1 ? '1' : '0';
//
//     final bool? result = await RoomDialog.show(
//       context,
//       isOnlyCancel: false,
//       title: 'Edit Room',
//       child: StatefulBuilder(
//         builder: (context, setDialogState) {
//           return Column(
//             children: [
//               Container(
//                 width: 350,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.only(left: 12),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     isExpanded: true,
//                     value: localStatus,
//                     hint: const Text(
//                       'Select Status',
//                       style: TextStyle(fontSize: 12, color: Colors.black),
//                     ),
//                     items: const [
//                       DropdownMenuItem(
//                         value: '1',
//                         child: Text('Active', style: TextStyle(fontSize: 12, color: Colors.black)),
//                       ),
//                       DropdownMenuItem(
//                         value: '0',
//                         child: Text('Inactive', style: TextStyle(fontSize: 12, color: Colors.black)),
//                       ),
//                     ],
//                     onChanged: (value) {
//                       if (value == null) return;
//                       setDialogState(() {
//                         localStatus = value;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 350,
//                 child: buildField(
//                   controller: roomNumberController,
//                   label: 'Room number',
//                   icon: Icons.meeting_room,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     if (result != true) return;
//
//     if (roomNumberController.text.trim().isEmpty) {
//       showCustomSnackBar(
//         context,
//         "Room number cannot be empty",
//         color: Colors.orange,
//       );
//       return;
//     }
//
//     LoadingScreen.show(context, message: 'Updating room...');
//
//     try {
//       final response = await ApiService().put(
//         'rooms/${room["id"]}',
//         {
//           'room_number': roomNumberController.text.trim(),
//           'is_active': int.tryParse(localStatus),
//         },
//         context,
//         true,
//       );
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//       }
//
//       if (response?.statusCode == 200) {
//       //  await loadSelectedApartmentRoom(activeApartment["id"]);
//
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             "Room updated successfully!",
//             color: Colors.green,
//           );
//         }
//       } else {
//         final errorData = jsonDecode(response!.body);
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             errorData['message'] ?? 'Failed to update room',
//             color: Colors.red,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(context, e.toString(), color: Colors.red);
//       }
//     } finally {
//       roomNumberController.dispose();
//     }
//   }
//
//   // ================= DELETE ROOM =================
//   Future<void> deleteRoom(int roomId) async {
//     final bool? confirm = await RoomDialog.show(
//       context,
//       title: 'Delete Room',
//       isOnlyCancel: false,
//       child: const Text('Are you sure you want to delete this room?'),
//     );
//
//     if (confirm != true) return;
//
//     LoadingScreen.show(context, message: 'Deleting room...');
//
//     try {
//       final response = await ApiService().delete(
//         'rooms/$roomId',
//         context,
//         true,
//       );
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//       }
//
//       if (response?.statusCode == 200) {
//        // await loadSelectedApartmentRoom(activeApartment["id"]);
//
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             "Room deleted successfully!",
//             color: Colors.green,
//           );
//         }
//       } else {
//         final errorData = jsonDecode(response!.body);
//         if (mounted) {
//           showCustomSnackBar(
//             context,
//             errorData['message'] ?? 'Failed to delete room',
//             color: Colors.red,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(context, e.toString(), color: Colors.red);
//       }
//     }
//   }
//
//   // ================= BULK DELETE ROOMS =================
//   Future<void> _handleBulkRoomDelete(List<Map<String, dynamic>> selectedItems) async {
//     final bool? confirm = await RoomDialog.show(
//       context,
//       title: 'Confirm Delete',
//       isOnlyCancel: false,
//       child: Text(
//         'Are you sure you want to delete ${selectedItems.length} Room${selectedItems.length > 1 ? 's' : ''}? This action cannot be undone.',
//         style: const TextStyle(fontSize: 14),
//       ),
//     );
//
//     if (confirm != true) return;
//
//     LoadingScreen.show(context, message: 'Deleting Rooms...');
//
//     try {
//       for (var item in selectedItems) {
//         await ApiService().delete('rooms/${item['id']}', context, true);
//       }
//
//      // await loadSelectedApartmentRoom(activeApartment["id"]);
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(
//           context,
//           '${selectedItems.length} Room${selectedItems.length > 1 ? 's' : ''} deleted successfully',
//           color: Colors.green,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(
//           context,
//           'Failed to delete Rooms: ${e.toString()}',
//           color: Colors.red,
//         );
//       }
//     }
//   }
//
//   // ================= BULK DELETE APARTMENTS =================
//   Future<void> _handleBulkApartmentDelete(List<Map<String, dynamic>> selectedItems) async {
//     final bool? confirm = await RoomDialog.show(
//       context,
//       title: 'Confirm Delete',
//       isOnlyCancel: false,
//       child: Text(
//         'Are you sure you want to delete ${selectedItems.length} Apartment${selectedItems.length > 1 ? 's' : ''}? This action cannot be undone.',
//         style: const TextStyle(fontSize: 14),
//       ),
//     );
//
//     if (confirm != true) return;
//
//     LoadingScreen.show(context, message: 'Deleting Apartments...');
//
//     try {
//       for (var item in selectedItems) {
//         await ApiService().delete('apartments/${item['id']}', context, true);
//       }
//
//       await loadApartmentData();
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(
//           context,
//           '${selectedItems.length} Apartment${selectedItems.length > 1 ? 's' : ''} deleted successfully',
//           color: Colors.green,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(
//           context,
//           'Failed to delete Apartments: ${e.toString()}',
//           color: Colors.red,
//         );
//       }
//     }
//   }
//
//   // ================= BULK EDIT ROOMS =================
//   Future<void> _handleBulkRoomEdit(List<Map<String, dynamic>> selectedItems) async {
//     String tempSelectedRoomId = '1';
//
//     final bool? confirm = await RoomDialog.show(
//       context,
//       title: 'Edit Rooms',
//       isOnlyCancel: false,
//       child: StatefulBuilder(
//         builder: (context, setDialogState) {
//           return Container(
//             width: 350,
//             height: kFieldHeight,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             margin: const EdgeInsets.only(bottom: 0),
//             padding: const EdgeInsets.only(left: 12),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 isExpanded: true,
//                 value: tempSelectedRoomId,
//                 hint: const Text('Select Status'),
//                 items: const [
//                   DropdownMenuItem(value: '1', child: Text('Active')),
//                   DropdownMenuItem(value: '0', child: Text('Inactive')),
//                 ],
//                 onChanged: (value) {
//                   if (value == null) return;
//                   setDialogState(() {
//                     tempSelectedRoomId = value;
//                   });
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//
//     if (confirm != true) return;
//
//     LoadingScreen.show(context, message: 'Updating Rooms...');
//
//     try {
//       for (var room in selectedItems) {
//         await ApiService().put(
//           'rooms/${room["id"]}',
//           {
//             'room_number': room["room_number"],
//             'is_active': int.tryParse(tempSelectedRoomId),
//           },
//           context,
//           true,
//         );
//       }
//
//      // await loadSelectedApartmentRoom(activeApartment["id"]);
//
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(
//           context,
//           '${selectedItems.length} Room${selectedItems.length > 1 ? 's' : ''} edited successfully',
//           color: Colors.green,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         LoadingScreen.hide(context);
//         showCustomSnackBar(
//           context,
//           'Failed to edit rooms: ${e.toString()}',
//           color: Colors.red,
//         );
//       }
//     }
//   }
//
//   // ================= BULK EXPORT =================
//   void _handleBulkExport(List<Map<String, dynamic>> selectedItems) async {
//     LoadingScreen.show(
//       context,
//       message: 'Exporting ${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''}...',
//     );
//
//     await Future.delayed(const Duration(seconds: 2));
//
//     if (mounted) {
//       LoadingScreen.hide(context);
//       showCustomSnackBar(
//         context,
//         '${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''} exported successfully to CSV',
//         color: Colors.orange,
//       );
//     }
//   }
//
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // ================= APARTMENTS =================
//         Expanded(
//           child: Column(
//             children: [
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 250,
//                       child: buildField(
//                         controller: addNewApartmentController,
//                         label: 'Apartment name',
//                         icon: Icons.apartment,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     CustomButton(
//                       text: 'Add',
//                       color: Colors.amber.shade700,
//                       isShowIcon: false,
//                       icon: Icons.add,
//                       onPressed: addNewApartment,
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: CustomDataTable(
//                     title: 'Apartments',
//                     data: apartments,
//                     headers: const ['name', 'created_at'],
//                     flexValues: const [2, 1],
//                     showSearch: true,
//                     showCheckbox: true,
//                     onBulkDelete: _handleBulkApartmentDelete,
//                     onBulkExport: _handleBulkExport,
//                     onRowTap: (rowData) {
//                       loadSelectedApartmentRoom(rowData);
//                     },
//                     mobileHeaders: const ['name', 'created_at'],
//                     mobileFlexValues: const [2, 1],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // ================= ROOMS =================
//         Expanded(
//           child: Column(
//             children: [
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 250,
//                       child: buildField(
//                         controller: addNewRoomController,
//                         label: 'Room number',
//                         icon: Icons.meeting_room,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     CustomButton(
//                       text: 'Add',
//                       color: Colors.amber.shade700,
//                       isShowIcon: false,
//                       onPressed: addNewRoom,
//                       icon: Icons.add,
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: SelectedRoomTable(
//                   data: roomList,
//                   title: activeApartment.isNotEmpty
//                       ? activeApartment["name"]
//                       : "Select Apartment",
//                   onTap: (Map<String, dynamic> roomData) async {
//                     await updateRoom(roomData);
//                   },
//                   onEdit: (Map<String, dynamic> roomData) async {
//                     await updateRoom(roomData);
//                   },
//                   onDelete: _handleBulkRoomDelete,
//                   onBulkEdit: _handleBulkRoomEdit,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fms_app/components/apartments_and_rooms/selectedRoomlist.dart';
import '../../providers/app_Manager.dart';
import '../../providers/constants.dart';
import '../../screens/dailogs/room.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/custom_table.dart';
import '../../widgets/loading.dart';
import '../../widgets/textform.dart';

class ApartmentTable extends StatefulWidget {
  const ApartmentTable({super.key});

  @override
  State<ApartmentTable> createState() => _ApartmentTableState();
}

class _ApartmentTableState extends State<ApartmentTable>
    with SingleTickerProviderStateMixin {
  final TextEditingController addNewApartmentController =
      TextEditingController();
  final TextEditingController addNewRoomController = TextEditingController();

  List<Map<String, dynamic>> apartments = [];
  List<Map<String, dynamic>> roomList = [];
  Map<String, dynamic> selectedApartment ={};
  Map<String, dynamic> activeApartment = {};
bool isFetchingIssues = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    loadApartmentData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    addNewApartmentController.dispose();
    addNewRoomController.dispose();
    super.dispose();
  }

  // ================= LOAD ALL APARTMENTS =================
  Future<void> loadApartmentData() async {
    try {
      setState(() {
        isFetchingIssues = true;
      });
      int? companyId = AppManager().loginResponse["user"]["company_id"];

      if (companyId == null) {
        showCustomSnackBar(context, 'Company ID not found');
        return;
      }

      final response = await ApiService().get('apartments/$companyId', context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        final responseData = jsonDecode(response!.body);

        setState(() {
          apartments = List<Map<String, dynamic>>.from(responseData["data"]);

          if (apartments.isNotEmpty) {
            activeApartment = apartments.first;
          }
        });
      } else {
        final responseData = jsonDecode(response!.body);
        showCustomSnackBar(context, responseData["message"]);
      }
      setState(() {
        isFetchingIssues = false;
      });
    } catch (e) {
      debugPrint('❌ API error: $e');
      if (mounted) {
        showCustomSnackBar(context, 'Network Error');
      }
      setState(() {
        isFetchingIssues = false;
      });
    }
  }

  // ================= LOAD ROOM FROM APARTMENT =================
  Future<void> loadSelectedApartmentRoom(

  ) async {
    try {
      if (selectedApartment["rooms"] != []) {
        setState(() {
          activeApartment = selectedApartment;
          roomList = List<Map<String, dynamic>>.from(
            activeApartment["rooms"] ?? [],
          );
        });
      } else {
        showCustomSnackBar(context, 'Sorry, selected apartment has no rooms');
      }
    } catch (e) {
      debugPrint('❌ API error: $e');
      if (mounted) {
        showCustomSnackBar(context, 'Network Error');
      }
    }
  }

  // ================= ADD NEW APARTMENT =================
  Future<void> addNewApartment() async {
    if (addNewApartmentController.text.trim().isEmpty) {
      showCustomSnackBar(
        context,
        "You cannot add an empty apartment",
        color: Colors.orange,
      );
      return;
    }

    int? companyId = AppManager().loginResponse["user"]["company_id"];

    if (companyId == null) {
      showCustomSnackBar(context, 'Company ID not found');
      return;
    }

    LoadingScreen.show(context, message: 'Adding apartment...');

    try {
      final response = await ApiService().post(
        'apartments',
        {
          'name': addNewApartmentController.text.trim(),
          'company_id': companyId,
        },
        context,
        true,
      );

      if (mounted) {
        LoadingScreen.hide(context);
      }

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        addNewApartmentController.clear();
        await loadApartmentData();

        if (mounted) {
          showCustomSnackBar(
            context,
            "Apartment added successfully!",
            color: Colors.green,
          );
        }
      } else {
        final errorData = jsonDecode(response!.body);
        if (mounted) {
          showCustomSnackBar(
            context,
            errorData['message'] ?? 'Failed to add apartment',
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(context, e.toString(), color: Colors.red);
      }
    }
  }

  // ================= UPDATE APARTMENT =================
  Future<void> updateApartment() async {
    if (activeApartment.isEmpty) {
      showCustomSnackBar(
        context,
        "Please select an apartment first",
        color: Colors.orange,
      );
      return;
    }

    setState(() {
      addNewApartmentController.text = activeApartment["name"];
    });

    final bool? result = await RoomDialog.show(
      context,
      title: 'Update Apartment',
      isOnlyCancel: false,
      child: SizedBox(
        width: 350,
        child: buildField(
          controller: addNewApartmentController,
          label: 'Apartment name',
          icon: Icons.apartment,
        ),
      ),
    );

    if (result != true) return;

    LoadingScreen.show(context, message: 'Updating apartment...');

    try {
      final response = await ApiService().put(
        'apartments/${activeApartment["id"]}',
        {'name': addNewApartmentController.text.trim()},
        context,
        true,
      );

      if (mounted) {
        LoadingScreen.hide(context);
      }

      if (response?.statusCode == 200) {
        addNewApartmentController.clear();
        await loadApartmentData();

        if (mounted) {
          showCustomSnackBar(
            context,
            "Apartment updated successfully!",
            color: Colors.green,
          );
        }
      } else {
        final errorData = jsonDecode(response!.body);
        if (mounted) {
          showCustomSnackBar(
            context,
            errorData['message'] ?? 'Failed to update apartment',
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(context, e.toString(), color: Colors.red);
      }
    }
  }

  // ================= DELETE APARTMENT =================
  Future<void> deleteApartment(int apartmentId) async {
    final bool? confirm = await RoomDialog.show(
      context,
      title: 'Delete Apartment',
      isOnlyCancel: false,
      child: const Text(
        'Are you sure you want to delete this apartment? This action cannot be undone.',
      ),
    );

    if (confirm != true) return;

    LoadingScreen.show(context, message: 'Deleting apartment...');

    try {
      final response = await ApiService().delete(
        'apartments/$apartmentId',
        context,
        true,
      );

      if (mounted) {
        LoadingScreen.hide(context);
      }

      if (response?.statusCode == 200) {
        await loadApartmentData();

        if (mounted) {
          showCustomSnackBar(
            context,
            "Apartment deleted successfully!",
            color: Colors.green,
          );
        }
      } else {
        final errorData = jsonDecode(response!.body);
        if (mounted) {
          showCustomSnackBar(
            context,
            errorData['message'] ?? 'Failed to delete apartment',
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(context, e.toString(), color: Colors.red);
      }
    }
  }

  // ================= ADD NEW ROOM =================
  Future<void> addNewRoom() async {
    if (addNewRoomController.text.trim().isEmpty) {
      showCustomSnackBar(
        context,
        "Room number cannot be empty",
        color: Colors.orange,
      );
      return;
    }

    if (activeApartment.isEmpty || apartments.isEmpty) {
      showCustomSnackBar(
        context,
        "Select or create an apartment first",
        color: Colors.orange,
      );
      return;
    }

    LoadingScreen.show(context, message: 'Adding room...');

    try {
      final response = await ApiService().post(
        'rooms',
        {
          'apartment_id': activeApartment["id"],
          'room_number': capitalizeFirst(addNewRoomController.text.trim()),
          'is_active': 0,
        },
        context,
        true,
      );

      if (mounted) {

        LoadingScreen.hide(context);
      }

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        addNewRoomController.clear();

        if (mounted) {
         await loadApartmentData();
         for(var item in apartments) {
           if(selectedApartment["id"] == item["id"]){
             setState(() {
               selectedApartment = item;
               activeApartment = item;
               roomList = List<Map<String, dynamic>>.from(
                 activeApartment["rooms"] ?? [],
               );
             });
           }
         }
          loadSelectedApartmentRoom();
          showCustomSnackBar(
            context,
            "Room ${capitalizeFirst(addNewRoomController.text)} added successfully!",
            color: Colors.green,
          );


        }
      } else {
        final errorData = jsonDecode(response!.body);
        if (mounted) {
          showCustomSnackBar(
            context,
            errorData['message'] ?? 'Failed to add room',
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(context, e.toString(), color: Colors.red);
      }
    }
  }

  // ================= UPDATE ROOM =================
  Future<void> updateRoom(Map<String, dynamic> room) async {
    final roomNumberController = TextEditingController(
      text: room['room_number'],
    );

    String localStatus = room['is_active'] == 1 ? '1' : '0';

    final bool? result = await RoomDialog.show(
      context,
      isOnlyCancel: false,
      title: 'Edit Room',
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            children: [
              Container(
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.only(left: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: localStatus,
                    hint: const Text(
                      'Select Status',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '1',
                        child: Text(
                          'Active',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '0',
                        child: Text(
                          'Inactive',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        localStatus = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 350,
                child: buildField(
                  controller: roomNumberController,
                  label: 'Room number',
                  icon: Icons.meeting_room,
                ),
              ),
            ],
          );
        },
      ),
    );

    if (result != true) return;

    if (roomNumberController.text.trim().isEmpty) {
      showCustomSnackBar(
        context,
        "Room number cannot be empty",
        color: Colors.orange,
      );
      return;
    }

    LoadingScreen.show(context, message: 'Updating room...');

    try {
      final response = await ApiService().put(
        'rooms/${room["id"]}',
        {
          'room_number': roomNumberController.text.trim(),
          'is_active': int.tryParse(localStatus),
        },
        context,
        true,
      );

      if (mounted) {
        LoadingScreen.hide(context);
      }

      if (response?.statusCode == 200) {
        if (mounted) {
          showCustomSnackBar(
            context,
            "Room updated successfully!",
            color: Colors.green,
          );
        }
      } else {
        final errorData = jsonDecode(response!.body);
        if (mounted) {
          showCustomSnackBar(
            context,
            errorData['message'] ?? 'Failed to update room',
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(context, e.toString(), color: Colors.red);
      }
    } finally {
      roomNumberController.dispose();
    }
  }

  // ================= DELETE ROOM =================
  Future<void> deleteRoom(int roomId) async {
    final bool? confirm = await RoomDialog.show(
      context,
      title: 'Delete Room',
      isOnlyCancel: false,
      child: const Text('Are you sure you want to delete this room?'),
    );

    if (confirm != true) return;

    LoadingScreen.show(context, message: 'Deleting room...');

    try {
      final response = await ApiService().delete(
        'rooms/$roomId',
        context,
        true,
      );

      if (mounted) {
        LoadingScreen.hide(context);
      }

      if (response?.statusCode == 200) {
        if (mounted) {
          showCustomSnackBar(
            context,
            "Room deleted successfully!",
            color: Colors.green,
          );
        }
      } else {
        final errorData = jsonDecode(response!.body);
        if (mounted) {
          showCustomSnackBar(
            context,
            errorData['message'] ?? 'Failed to delete room',
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(context, e.toString(), color: Colors.red);
      }
    }
  }

  // ================= BULK DELETE ROOMS =================
  Future<void> _handleBulkRoomDelete(
    List<Map<String, dynamic>> selectedItems,
  ) async {
    final bool? confirm = await RoomDialog.show(
      context,
      title: 'Confirm Delete',
      isOnlyCancel: false,
      child: Text(
        'Are you sure you want to delete ${selectedItems.length} Room${selectedItems.length > 1 ? 's' : ''}? This action cannot be undone.',
        style: const TextStyle(fontSize: 14),
      ),
    );

    if (confirm != true) return;

    LoadingScreen.show(context, message: 'Deleting Rooms...');

    try {
      for (var item in selectedItems) {
        await ApiService().delete('rooms/${item['id']}', context, true);
      }

      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(
          context,
          '${selectedItems.length} Room${selectedItems.length > 1 ? 's' : ''} deleted successfully',
          color: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(
          context,
          'Failed to delete Rooms: ${e.toString()}',
          color: Colors.red,
        );
      }
    }
  }

  // ================= BULK DELETE APARTMENTS =================
  Future<void> _handleBulkApartmentDelete(
    List<Map<String, dynamic>> selectedItems,
  ) async {
    final bool? confirm = await RoomDialog.show(
      context,
      title: 'Confirm Delete',
      isOnlyCancel: false,
      child: Text(
        'Are you sure you want to delete ${selectedItems.length} Apartment${selectedItems.length > 1 ? 's' : ''}? This action cannot be undone.',
        style: const TextStyle(fontSize: 14),
      ),
    );

    if (confirm != true) return;

    LoadingScreen.show(context, message: 'Deleting Apartments...');

    try {
      for (var item in selectedItems) {
        await ApiService().delete('apartments/${item['id']}', context, true);
      }

      await loadApartmentData();

      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(
          context,
          '${selectedItems.length} Apartment${selectedItems.length > 1 ? 's' : ''} deleted successfully',
          color: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(
          context,
          'Failed to delete Apartments: ${e.toString()}',
          color: Colors.red,
        );
      }
    }
  }

  // ================= BULK EDIT ROOMS =================
  Future<void> _handleBulkRoomEdit(
    List<Map<String, dynamic>> selectedItems,
  ) async {
    String tempSelectedRoomId = '1';

    final bool? confirm = await RoomDialog.show(
      context,
      title: 'Edit Rooms',
      isOnlyCancel: false,
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Container(
            width: 350,
            height: kFieldHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(bottom: 0),
            padding: const EdgeInsets.only(left: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: tempSelectedRoomId,
                hint: const Text('Select Status'),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Active')),
                  DropdownMenuItem(value: '0', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() {
                    tempSelectedRoomId = value;
                  });
                },
              ),
            ),
          );
        },
      ),
    );

    if (confirm != true) return;

    LoadingScreen.show(context, message: 'Updating Rooms...');

    try {
      for (var room in selectedItems) {
        await ApiService().put(
          'rooms/${room["id"]}',
          {
            'room_number': room["room_number"],
            'is_active': int.tryParse(tempSelectedRoomId),
          },
          context,
          true,
        );
      }

      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(
          context,
          '${selectedItems.length} Room${selectedItems.length > 1 ? 's' : ''} edited successfully',
          color: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(
          context,
          'Failed to edit rooms: ${e.toString()}',
          color: Colors.red,
        );
      }
    }
  }

  // ================= BULK EXPORT =================
  void _handleBulkExport(List<Map<String, dynamic>> selectedItems) async {
    LoadingScreen.show(
      context,
      message:
          'Exporting ${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''}...',
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      LoadingScreen.hide(context);
      showCustomSnackBar(
        context,
        '${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''} exported successfully to CSV',
        color: Colors.orange,
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header Section
          _buildHeader(),

          const SizedBox(height: 16),

          // Main Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Property Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage apartments and rooms efficiently',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildStatsChip(
            '${apartments.length}',
            'Apartments',
            Icons.apartment,
          ),
          const SizedBox(width: 12),
          _buildStatsChip('${roomList.length}', 'Rooms', Icons.meeting_room),
        ],
      ),
    );
  }

  Widget _buildStatsChip(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(child: _buildApartmentsSection()),
        Container(
          width: 2,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.grey.shade300,
                Colors.transparent,
              ],
            ),
          ),
        ),
        Expanded(child: _buildRoomsSection()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 400, child: _buildApartmentsSection()),
          const SizedBox(height: 16),
          SizedBox(height: 400, child: _buildRoomsSection()),
        ],
      ),
    );
  }

  Widget _buildApartmentsSection() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.apartment,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Apartments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width:300,
                  child: buildField(
                    controller: addNewApartmentController,
                    label: 'Apartment name',
                    icon: Icons.apartment,
                  ),
                ),
                const SizedBox(width: 12),
                CustomButton(
                  text: 'Add',
                  color: Colors.blue,
                  isShowIcon: false,
                  onPressed: addNewApartment,
                  icon: Icons.add,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: CustomDataTable(
                title: 'All Apartments',
                data: apartments,
                isLoading: isFetchingIssues,
                autoLoadWhenEmpty: false,
                headers: const ['Name', 'Created_at'],
                flexValues: const [2, 1],
                showSearch: true,
                showCheckbox: true,
                showRefresh: true,
                onBulkDelete: _handleBulkApartmentDelete,
                onBulkExport: _handleBulkExport,
                onRowTap: (rowData) {
                  setState(() {
                    selectedApartment = rowData;
                  });
                  loadSelectedApartmentRoom();
                },
                onRefreshPressed: () {
                  loadApartmentData();
                },
                mobileHeaders: const ['Name', 'Created_at'],
                filterOptions: const ['Name'],
                filterLabel: 'Filter by Name',
                mobileFlexValues: const [2, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsSection() {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.meeting_room,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  activeApartment.isNotEmpty
                      ? "${activeApartment["name"]} Rooms"
                      : 'Rooms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height:16 ,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width:300,
                  child: buildField(
                    controller: addNewRoomController,
                    label: 'Room label',
                    icon: Icons.meeting_room,
                  ),
                ),
                const SizedBox(width: 12),
                CustomButton(
                  text: 'Add',
                  color: Colors.blue,
                  isShowIcon: false,
                  onPressed: addNewRoom,
                  icon: Icons.add,
                ),
              ],
            ),
          ),
          Expanded(
            child: SelectedRoomTable(
              data: roomList,
              title: "All Rooms",
              onTap: (Map<String, dynamic> roomData) async {
                await updateRoom(roomData);
              },
              onEdit: (Map<String, dynamic> roomData) async {
                await updateRoom(roomData);
              },
              onDelete: _handleBulkRoomDelete,
              onBulkEdit: _handleBulkRoomEdit,
              onRefresh: loadSelectedApartmentRoom,
            ),
          ),
        ],
      ),
    );
  }
}
