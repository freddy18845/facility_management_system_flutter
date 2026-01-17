import 'dart:convert';

import 'package:flutter/material.dart';
import '../providers/app_Manager.dart';
import '../screens/dailogs/fault_report.dart';
import '../screens/dailogs/query_dailog.dart';
import '../utils/api_service.dart';
import '../utils/app_theme.dart';
import 'custom_table.dart';
import 'loading.dart';

class RecentIncidents extends StatefulWidget {
  final bool isMobile;
  final double height;

  const RecentIncidents({
    super.key,
    this.isMobile = false,
    required this.height,
  });

  @override
  State<RecentIncidents> createState() => _RecentIncidentsState();
}

class _RecentIncidentsState extends State<RecentIncidents> {
  final companyId = AppManager().getCompanyId();
  bool isFetchingIssues = false;
  List<Map<String, dynamic>> incidentsData = [
  ];
  List<Map<String, dynamic>> artisanData=[];
  @override
  void initState() {
    super.initState();
    getIssuesByTenantAndCompany();
    loadArtisanData();

  }
  Future<void> loadArtisanData() async {
    try {
      int?  companyId = AppManager().loginResponse["user"]["company_id"];
      final response = await ApiService().get('artisans/$companyId', context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        final responseData = jsonDecode(response!.body);

        setState(() {
          artisanData = List<Map<String, dynamic>>.from(responseData['artisans']);

          // Set first apartment as active by default (if exists)

        });


        print(artisanData);
      } else {
        final responseData = jsonDecode(response!.body);
        showCustomSnackBar(context, responseData["message"]);
      }
    } catch (e) {
      debugPrint('❌ API error: $e');
      if (mounted) {
        showCustomSnackBar(context, 'Network Error');
      }
    }
  }
  Future<void> getIssuesByTenantAndCompany() async {
    try {
      setState(() {
        isFetchingIssues = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      final response = await ApiService().get(
        'issues/company/$companyId',
        context,
      );

      if (response?.statusCode == 200) {
        final responseData = jsonDecode(response!.body);

        if (responseData['success']) {
          setState(() {
            incidentsData = List<Map<String, dynamic>>.from(
              responseData['issues'] ?? [],
            );
          });
          print(incidentsData.toList());
        }
      }
    } catch (e) {
      showCustomSnackBar(context, 'Failed to load issues', color: Colors.red);
    } finally {
      setState(() {
        isFetchingIssues = false;
      });

    }
  }


  void _handleBulkAssign(List<Map<String, dynamic>> selectedItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.assignment, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Assign ${selectedItems.length} Task${selectedItems.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are about to assign the following incidents:'),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item['tenant']} - ${item['incident']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              LoadingScreen.show(
                context,
                message: 'Assigning tasks...',
              );

              // Simulate assignment delay
              await Future.delayed(const Duration(seconds: 2));

              // Hide loading
              LoadingScreen.hide(context);

              // Show success message
              showCustomSnackBar(
                context,
                '${selectedItems.length} task${selectedItems.length > 1 ? 's' : ''} assigned successfully',
                color: Colors.green,
              );

              // TODO: Add your actual assignment logic here
              for (var item in selectedItems) {
                print('Assigning: ${item['incident']}');
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Assign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBulkDelete(List<Map<String, dynamic>> selectedItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${selectedItems.length} incident${selectedItems.length > 1 ? 's' : ''}? This action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              LoadingScreen.show(
                context,
                message: 'Deleting incidents...',
              );

              // // Simulate delete delay
              // await Future.delayed(const Duration(seconds: 2));

              // Perform deletion
              setState(() {
                incidentsData.removeWhere((item) => selectedItems.contains(item));
              });

              // Hide loading
              LoadingScreen.hide(context);

              // Show success message
              showCustomSnackBar(
                context,
                '${selectedItems.length} incident${selectedItems.length > 1 ? 's' : ''} deleted successfully',
                color: Colors.red,
              );
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBulkExport(List<Map<String, dynamic>> selectedItems) async {
    // Show loading immediately
    LoadingScreen.show(
      context,
      message: 'Exporting ${selectedItems.length} incident${selectedItems.length > 1 ? 's' : ''}...',
    );

    // Simulate export delay
    await Future.delayed(const Duration(seconds: 3));

    // Hide loading
    if (mounted) {
      LoadingScreen.hide(context);

      // Show success message
      showCustomSnackBar(
        context,
        '${selectedItems.length} incident${selectedItems.length > 1 ? 's' : ''} exported successfully to CSV',
        color: Colors.orange,
      );

      // TODO: Add your actual export logic here
      print('Exporting ${selectedItems.length} items');
      for (var item in selectedItems) {
        print('Export: ${item['tenant']} - ${item['incident']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDataTable(
      title: 'Recent Request',
      height: widget.height,

      // Enable checkbox and bulk actions
      showPagination: true,
      itemsPerPage: 5,
      showCheckbox: true,
      showRefresh: true,

      isLoading: isFetchingIssues,
      autoLoadWhenEmpty: false,
      onBulkAction: _handleBulkAssign,
      onBulkDelete: _handleBulkDelete,
      onBulkExport: _handleBulkExport,

      // Query button handler
      onRefreshPressed: () {
        getIssuesByTenantAndCompany();
      },

      // Optional: Track selection changes
      onSelectionChanged: (selectedItems) {
        print('${selectedItems.length} items selected');
      },

      // Desktop headers
      headers: const [
        'Tenant',
        'Contact',
        'Location',
        'Apartment',
        'Room',
        'IssueType',
        'Priority',
        'Status',
      ],

      // Mobile headers
      mobileHeaders: const [
        'Tenant',
        'IssueType',
        'Priority',
        'Status',
      ],

      // Desktop flex values
      flexValues: const [1, 1, 1, 1, 1, 1, 1, 1],

      // Mobile flex values
      mobileFlexValues: const [1, 1, 1, 1],

      // Data
      data: incidentsData,

      // Enable features
      showSearch: true,
      showFilter: false,
      showDateRange: true,

      // Filter options

      // Row tap handler
      onRowTap: (rowData) async {

      bool? isComplete = await  FaultReportDialog.show(context, rowData,artisanData);
      if(isComplete!){
        getIssuesByTenantAndCompany();
      }
      },
    );
  }
}