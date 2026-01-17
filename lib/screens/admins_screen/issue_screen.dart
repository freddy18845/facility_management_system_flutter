
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../providers/app_Manager.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_table.dart';
import '../dailogs/fault_report.dart';
import '../dailogs/query_dailog.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  List<Map<String, dynamic>> incidentsData = [];
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;
  bool _hasError = false;
  Timer? _loadingTimeout;
  List<Map<String, dynamic>> artisanData=[];
  @override
  void initState() {
    super.initState();
    endDate = DateTime.now();
    startDate = endDate!.subtract(const Duration(days: 31));
    loadArtisanData();
    loadIncidents(startDate: startDate!, endDate: endDate!);
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
  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> loadIncidents({required DateTime startDate, required DateTime endDate}) async {
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

      Map<String, dynamic> params = {
        'company_id': companyId,
        'start_date': formatDate(startDate),
        'end_date': formatDate(endDate),
      };

      http.Response? response = await ApiService().get(
        'admin/issues',
        context,
        params: params,
      );

      if (response?.statusCode == 200) {
        final responseData = jsonDecode(response!.body);
        print("Response Data: $responseData");

        setState(() {
          incidentsData = List<Map<String, dynamic>>.from(responseData['issues'] ?? []);
          _hasError = incidentsData.isEmpty;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Incident load error: $e');
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



  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomDataTable(
          title: 'Issues List',
          height: double.maxFinite,
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
          mobileHeaders: const ['Tenant', 'IssueType', 'Priority', 'Status'],
          data: incidentsData,
          flexValues: const [1, 1, 1, 1, 1, 1, 1, 1],
          mobileFlexValues: const [1, 1, 1, 1],
          showPagination: true,
          isLoading: isLoading,
          itemsPerPage: 50,
          showCheckbox: true,
          showEditBtn: true,
          showDateRange: true,
          showSearch: true,
          showFilter: true,
          showRefresh: true,
          autoLoadWhenEmpty: false,
          onQueryPressed: () async {
            final result = await QueryDialog.show(context);
            if (result != null) {
              startDate = result.first['start_date'];
              endDate = result.first['end_date'];
              loadIncidents(startDate: startDate!, endDate: endDate!);
            }
          },
          onRefreshPressed: (){
            loadIncidents(startDate: startDate!, endDate: endDate!);
          },
          // Query button handler
          onRowTap: (rowData) {
            FaultReportDialog.show(context, rowData, artisanData);
          },
          filterOptions: const ['Tenant', 'Priority', 'Room','Status','Location'],
          filterLabel: 'Filter by All Field',
        ),
      ),
    );
  }
}
