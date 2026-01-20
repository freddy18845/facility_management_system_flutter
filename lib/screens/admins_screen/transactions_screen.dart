import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fms_app/screens/dailogs/confirnation_dailog.dart';
import '../../components/admin_sub_screen/header.dart';
import '../../providers/app_Manager.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/custom_table.dart';
import '../dailogs/payment_upgrade_dialog.dart';

class TransactionsPage extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final bool isMobile;

  const TransactionsPage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> transactionData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadTransactionHistory();
  }

  Future<void> loadTransactionHistory() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService().get('payments/transactions/company', context);

      if (response?.statusCode == 200) {
        final responseData = jsonDecode(response!.body);

        setState(() {
          // Ensure we map the data correctly based on your API structure
          transactionData = List<Map<String, dynamic>>.from(
            responseData['data'] ?? [],
          );
        });
      } else {
        final responseData = jsonDecode(response!.body);
        showCustomSnackBar(context, responseData["message"] ?? "Failed to load transactions");
      }
    } catch (e) {
      debugPrint('❌ API error: $e');
      if (mounted) showCustomSnackBar(context, 'Network Error');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  void verifyPayment({
    required String activeReference,
  }) async {

  bool? result=  await ConfirmationDialog.show(
      context,
      title: 'Verify Payment',
      message: 'Are you sure you want to verify your payments?'
    );

    if(result!){
      await ApiService().verifyOnServer(context, activeReference);
      if (!mounted) Navigator.pop(context);
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
            icon: Icons.account_balance_wallet_rounded,
            title: 'Payment History',
            subtitle: 'Monitor your payments history (Subscription and Sms Top-up)',
            child: CustomButton(
              icon: Icons.add,
              text: 'Make payment',
              color: Colors.amber.shade700,
              isShowIcon: false,
              onPressed: () {
                PaymentUpgradeDialog.show(context);
              },
            ), // No "Add New" button for history
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomDataTable(
                    title: 'Payment Records',
                    height: constraints.maxHeight - 32,
                    showPagination: true,
                    itemsPerPage: 20,
                    isLoading: isLoading,
                    autoLoadWhenEmpty: false,
                    showCheckbox: false, // Usually not needed for history
                    showEditBtn: false,      // History should be read-only
                    showRefresh: true,

                    // Column Headers matching your Database fields
                    headers: const [
                      'Reference',
                      'Type',
                      'Amount',
                      'Quantity',
                      'Status',
                      'Created_at'
                    ],

                    mobileHeaders: const [
                      'Reference',
                      'Amount',
                      'Status'
                    ],

                    flexValues: const [1, 1, 1, 1, 1, 1],
                    mobileFlexValues: const [1, 1, 1],

                    filterOptions: const ['Reference', 'Type', 'Status'],
                    filterLabel: 'Search by Reference or Type',

                    data: transactionData,

                    showSearch: true,
                    showFilter: true,
                    showDateRange: true,

                    onRefreshPressed: () {
                      loadTransactionHistory();
                    },
                    onRowTap: (rowData) {
                      // Optional: Show a receipt dialog or details
                     // verifyPayment(activeReference: rowData['reference']);
                      //debugPrint('Selected Transaction: ${rowData['reference']}');
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