import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/date_card.dart';

class QueryDialog extends StatefulWidget {
  const QueryDialog({super.key});

  static Future<List<Map<String, dynamic>>?> show(BuildContext context) {
    return showDialog<List<Map<String, dynamic>>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const QueryDialog(),
    );
  }

  @override
  State<QueryDialog> createState() => _QueryDialogState();
}

class _QueryDialogState extends State<QueryDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ===============================
  // Helpers
  // ===============================
  void _showError(String message) {
    showCustomSnackBar(context, message, color: Colors.red);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ===============================
  // Date Pickers
  // ===============================
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;

        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      _showError('Please select start date first');
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  // ===============================
  // Submit
  // ===============================
  void _submit() {
    if (_startDate == null) {
      _showError('Start date is required');
      return;
    }

    if (_endDate == null) {
      _showError('End date is required');
      return;
    }

    Navigator.of(context).pop([
      {
        'start_date': _formatDate(_startDate!),
        'end_date': _formatDate(_endDate!),
      }
    ]);
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: size.height * 0.45,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            const DialogHeader(title: 'Search By Date'),

            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buildDateSelector(
                                label: 'Start Date *',
                                date: _startDate,
                                onTap: _selectStartDate,
                                icon: Icons.calendar_today,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildDateSelector(
                                label: 'End Date *',
                                date: _endDate,
                                onTap: _selectEndDate,
                                icon: Icons.event,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (_startDate != null && _endDate != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border:
                              Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Range: ${_endDate!.difference(_startDate!).inDays + 1} day(s)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            DialogBottomNavigator(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () => Navigator.pop(context),
                  ),
                  CustomButton(
                    text: 'Query',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
