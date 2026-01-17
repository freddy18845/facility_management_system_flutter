import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../components/admin_sub_screen/header.dart';
import '../../providers/app_Manager.dart';
import '../../providers/constants.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/custom_table.dart';
import '../../widgets/loading.dart';
import '../../widgets/textform.dart';
import '../dailogs/query_dailog.dart';
import '../dailogs/sms_dailog.dart';
import '../dailogs/tenant_dailog.dart';

class TenantPage extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final bool isMobile;

  const TenantPage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<TenantPage> createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool _hasError = false;
  List<Map<String, dynamic>> tenantsData = [];
  DateTime? startDate;
  DateTime? endDate;
  Timer? _loadingTimeout;

  @override
  void initState() {
    super.initState();
    loadApartmentData();
    loadTenantData();

  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  // ✅ Format Date to yyyy-MM-dd
  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> loadTenantData({bool isRetry = false}) async {
    setState(() {
      isLoading = true;
      _hasError = false;
    });

    // ⏱ Auto-stop shimmer after 8 seconds
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 8), () {
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
          _hasError = true;
        });
      }
    });

    try {
      int companyId = AppManager().loginResponse["user"]["company_id"];
      Map<String, dynamic>? params;

      // Only add dates if both are set
      if (startDate != null && endDate != null) {
        params = {
          'start_date': formatDate(startDate!),
          'end_date': formatDate(endDate!),
        };
      }

      http.Response? response = await ApiService().get(
        'tenants/$companyId',
        context,
        params: params,
      );

      if (response?.statusCode == 200) {
        final responseData = jsonDecode(response!.body);
        print("Response Data: $responseData");

        setState(() {
          tenantsData = List<Map<String, dynamic>>.from(
            responseData["tenants"] ?? [],
          );
          _hasError = tenantsData.isEmpty;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Tenant load error: $e');
      setState(() {
        _hasError = true;
      });
    } finally {
      _loadingTimeout?.cancel();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Retry handler
  void _retryLoad() {
    loadTenantData(isRetry: true);
  }

  Future<void> loadApartmentData() async {
    try {
      setState(() {
        isLoading = true;
      });
      int? companyId = AppManager().loginResponse["user"]["company_id"];
      final response = await ApiService().get('apartments/$companyId', context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        final responseData = jsonDecode(response!.body);
        print("Response Data1: $responseData");
        setState(() {
          selectedApartmentRoomList = List<Map<String, dynamic>>.from(
            responseData["data"],
          );
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

  void _handleBulkExport(List<Map<String, dynamic>> selectedItems) async {
    // Show loading immediately
    LoadingScreen.show(
      context,
      message:
          'Exporting ${selectedItems.length} incident${selectedItems.length > 1 ? 's' : ''}...',
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        adminSubHeader(
          newContext: context,
          icon: Icons.apartment,
          title: 'Company Tenants',
          child: CustomButton(
            icon: Icons.add,
            text: 'New Tenant',
            color: Colors.amber.shade700,
            onPressed: () async {
            bool?  result = await TenantDialog.show(context);
            if(result!){
              _retryLoad();
            }
            },
          ),
          subtitle: 'Manage our company tenants efficiently',
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CustomDataTable(
              title: 'Tenants List',
              headers: const [
                'Fullname',
                'Contact',
                'Email',
                'Apartment',
                'Room',
                'Occupation',
                'Move in date',
                'Lease end date',
              ],
              mobileHeaders: const ['Fullname', 'Contact', 'Apartment', 'Room'],
              data: () {
                debugPrint(
                  '🔢 Data passed to table: ${tenantsData.length} items',
                );
                if (tenantsData.isNotEmpty) {
                  debugPrint(
                    '🔍 First item keys: ${tenantsData.first.keys.toList()}',
                  );
                }
                return tenantsData;
              }(),
              flexValues: const [2, 1, 2, 1, 1, 1, 1, 1, 1],
              mobileFlexValues: const [2, 1, 1, 1],
              isLoading: isLoading,
              autoLoadWhenEmpty: false,
              showPagination: true,
              itemsPerPage: 15,
              showCheckbox: true,
              showEditBtn: true,
              showDateRange: true,
              showSearch: true,
              showFilter: true,
              showRefresh: true,
              action: 'SMS',
              actionIcon: Icons.chat_outlined,
              onBulkAction: _handleBulkSMS,
              onBulkExport: _handleBulkExport,
              filterOptions: const [
                'Fullname',
                'Apartment',
                'Room',
                'Location',
                'Contact',
              ],
              filterLabel: 'Filter by name',
              onQueryPressed: () async {
                final result = await QueryDialog.show(context);
                if (result != null) {
                  startDate = result.first['start_date'];
                  endDate = result.first['end_date'];
                  loadTenantData();
                }
              },
              // Row tap handler
              onRowTap: (rowData) async {
                bool? isSuccessful = await TenantDialog.show(
                  context,
                  data: rowData,
                );
                if (isSuccessful!) {
                  _retryLoad();
                }
              },
              onRefreshPressed: () {
               _retryLoad();
              },
              onEditBtn: (rowData) async {
                bool? isSuccessful = await TenantDialog.show(
                  context,
                  data: rowData,
                );
                if (isSuccessful!) {
                  _retryLoad();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
