import 'dart:convert';
import 'package:flutter/material.dart';
import '../../components/admin_sub_screen/header.dart';
import '../../providers/app_Manager.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_table.dart';
import '../../widgets/loading.dart';
import '../dailogs/artisan.dart';
import '../dailogs/room.dart';
import '../dailogs/sms_dailog.dart';

class ArtisanPage extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final bool isMobile;
  const ArtisanPage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<ArtisanPage> createState() => _ArtisanPageState();
}

class _ArtisanPageState extends State<ArtisanPage>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  List<Map<String, dynamic>> artisanData = [];
 bool isFetchingIssues = false;
  String localStatus ='';
  final List<Map<String, dynamic>> roleList = [
    {"status":"1", "role":"Active"},
    {"status":"0", "role":"Inactive"},
  ];

  Map<String, dynamic> selectedRole = {"status":"1", "role":"Active"};
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
        isFetchingIssues = true;
      });
      int? companyId = AppManager().loginResponse["user"]["company_id"];
      final response = await ApiService().get('artisans/$companyId', context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        final responseData = jsonDecode(response!.body);

        setState(() {
          artisanData = List<Map<String, dynamic>>.from(
            responseData['artisans'],
          );

          // Set first apartment as active by default (if exists)
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


    final bool? result = await RoomDialog.show(
      context,
      isOnlyCancel: false,
      title: 'Edit Artisan Status',
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Container(
            height: 65,
            width: 350,
            child: CustomDropdown(
              label: 'Status',
              icon: Icons.perm_contact_cal,
              items: roleList,
              value: selectedRole,
              displayText: (item) => item['role'],
              onSelected: (item) {
                if (item['role'] == null) return;
                setDialogState(() {
                  selectedRole= item;
                  localStatus = item['role']; // ✅ updates instantly
                });
              },
            ),
          );
        },
      ),
    );

    if (result == true) {
      LoadingScreen.show(context, message: 'Updating status...');

      await ApiService().put(
        'artisans/${room["id"]}/status',
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
    return Column(
      children: [
        adminSubHeader(
          newContext: context,
          icon: Icons.engineering,
          title: 'Company Artisans',
          child: CustomButton(
            icon: Icons.add,
            text: 'New Artisan',
            color: Colors.amber.shade700,
            onPressed: () async {
           bool? result= await   ArtisanDialog.show(context, {});
           if(result!){
             loadArtisanData();
           }
            },
          ),
          subtitle: 'Manage our company artisan efficiently',
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.all(16),

                child: CustomDataTable(
                  title: 'Artisan List',
                  height: constraints.maxHeight - 32,
                  showPagination: true,
                  itemsPerPage: 15,
                  showRefresh: true,
                  isLoading: isFetchingIssues,
                  autoLoadWhenEmpty: false,
                  actionIcon: Icons.chat_outlined,
                  showCheckbox: true,
                  showEditBtn: true,
                  action: 'SMS',
                  onBulkAction: _handleBulkSMS,

                  //onBulkExport: changeStatus,
                  headers: const [
                    'Fullname', // Changed from 'FullName'
                    'Contact', // Changed from 'Contact'
                    'Email', // Changed from 'Email'
                    'Location', // Changed from 'Location'
                    'Skill', // Changed from 'Skill'
                    'Status', // Changed from 'Status'
                  ],

                  mobileHeaders: const [
                    'fullname',
                    'contact',
                    'skill',
                    'status',
                  ],

                  flexValues: const [2, 1, 2, 1, 1, 1],
                  mobileFlexValues: const [2, 1, 1, 1],

                  // Debug: Print data length
                  data: () {
                    debugPrint(
                      '🔢 Data passed to table: ${artisanData.length} items',
                    );
                    if (artisanData.isNotEmpty) {
                      debugPrint(
                        '🔍 First item keys: ${artisanData.first.keys.toList()}',
                      );
                    }
                    return artisanData;
                  }(),

                  showSearch: true,
                  showFilter: true,
                  showDateRange: true,

                  filterOptions: const [
                    'FullName',
                    'Contact',
                    'Email',
                    'Location',
                    'Skill',
                  ],

                  onRowTap: (rowData) {
                    changeStatus(rowData);
                    // ArtisanDialog.show(context,rowData);
                  },
                  onRefreshPressed: (){
                    loadArtisanData() ;
                  },
                  onEditBtn: (rowData) async {
                    bool? result= await   ArtisanDialog.show(context, rowData);
                    if(result!){
                      loadArtisanData();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
