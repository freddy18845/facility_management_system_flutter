import 'dart:convert';

import 'package:flutter/material.dart';
import '../../components/admin_sub_screen/header.dart';
import '../../providers/app_Manager.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/custom_table.dart';
import '../../widgets/loading.dart';
import '../dailogs/artisan.dart';
import '../dailogs/room.dart';
import '../dailogs/sms_dailog.dart';
import '../dailogs/user.dart';

class UsersPage extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final bool isMobile;

  const UsersPage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  List<Map<String, dynamic>> staffData = [];
  bool isLoading = false;
  late String selectedRoomId = '';

  @override
  void initState() {
    super.initState();
    loadArtisanData();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  Future<void> loadArtisanData() async {
    try {
      setState(() {
        isLoading = true;
      });
      int? companyId = AppManager().loginResponse["user"]["company_id"];
      final response = await ApiService().get('users/$companyId', context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        final responseData = jsonDecode(response!.body);

        setState(() {
          staffData = List<Map<String, dynamic>>.from(
            responseData['data'],
          );

          // Set first apartment as active by default (if exists)
        });
      } else {
        final responseData = jsonDecode(response!.body);
        showCustomSnackBar(context, responseData["message"]);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ API error: $e');
      if (mounted) {
        showCustomSnackBar(context, 'Network Error');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleBulkSMS(List<Map<String, dynamic>> selectedItems) {
    SmsDialog.show(
      context,
      contacts: selectedItems,
      onSubmit: () {
        print('SMS sent successfully!');
        showCustomSnackBar(
          context,
          'SMS sent successfully',
          color: Colors.green,
        );
      },
    );
  }

  Future<void> changeStatus(Map<String, dynamic> room) async {
    String localStatus =
    room['status'] == 1 ||
        room['status'] == '1' ||
        room['status'] == 'Active'
        ? '1'
        : '0';

    final bool? result = await RoomDialog.show(
      context,
      isOnlyCancel: false,
      title: 'Edit Staff Status',
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.only(left: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: localStatus,
                hint: const Text(
                  'Select Status',
                  style: TextStyle(fontSize: 12),
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Active')),
                  DropdownMenuItem(value: '0', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setDialogState(() {
                    localStatus = value; // ✅ updates instantly
                  });
                },
              ),
            ),
          );
        },
      ),
    );

    if (result == true) {
      LoadingScreen.show(context, message: 'Updating status...');

      await ApiService().put(
        'users/',
        {'status': localStatus},
        context,
        true,
      );

      LoadingScreen.hide(context);
      loadArtisanData(); // refresh table
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          adminSubHeader(
            newContext: context,
            icon: Icons.person_add_rounded,
            title: 'Management Staffs',
            child: CustomButton(
              icon: Icons.add,
              text: 'New Staff',
              color: Colors.amber.shade700,
              onPressed: () {
                UserDialog.show(context, {});
              },
            ),
            subtitle: 'Manage your department staffs',
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.all(16),

                  child: CustomDataTable(
                    title: 'Staff List',
                    height: constraints.maxHeight - 32,
                    showPagination: true,
                    itemsPerPage: 15,
                    isLoading: isLoading,
                    autoLoadWhenEmpty: false,
                    actionIcon: Icons.chat_outlined,
                    showCheckbox: true,
                    showEditBtn: true,
                    showRefresh: true,
                    action: 'SMS',
                    onBulkAction: _handleBulkSMS,

                    //onBulkExport: changeStatus,
                    headers: const [
                      'Fullname', // Changed from 'FullName'
                      'Email', // Changed from 'Email'
                      'Contact',
                      'Role', // Changed from 'Skill'
                      'Created_at'
                    ],

                    mobileHeaders: const [
                      'Fullname',
                      'Email'
                      'Contact',
                      'Role',
                      'Created_at'
                    ],

                    flexValues: const [2, 2, 1, 1, 1],
                    mobileFlexValues: const [1, 1, 1, 1],
                    filterOptions: const ['Fullname','Email','Contact','Role'],
                    filterLabel: 'Filter by FullName, Email, Contact, Role',
                    // Debug: Print data length
                    data: () {
                      debugPrint(
                        '🔢 Data passed to table: ${staffData.length} items',
                      );
                      if (staffData.isNotEmpty) {
                        debugPrint(
                          '🔍 First item keys: ${staffData.first.keys.toList()}',
                        );
                      }
                      return staffData;
                    }(),

                    showSearch: true,
                    showFilter: true,
                    showDateRange: true,

                    onRefreshPressed: () {
                      loadArtisanData();
                    },
                    onRowTap: (rowData) {
                      changeStatus(rowData);
                      // ArtisanDialog.show(context,rowData);
                    },
                    onEditBtn: (rowData) {
                      UserDialog.show(context, rowData);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}