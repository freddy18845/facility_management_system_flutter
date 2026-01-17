import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import '../../components/dailog_widgets/issues_dailog_summary_data.dart';
import '../../providers/app_Manager.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading.dart';
import '../../widgets/textform.dart';
import 'confirnation_dailog.dart';
import 'image_viewer_dailog.dart';

class FaultReportDialog extends StatefulWidget {
  final Map<String, dynamic> faultReport;
  final List<Map<String, dynamic>> artisanData;

  const FaultReportDialog({
    super.key,
    required this.faultReport,
    required this.artisanData,
  });

  @override
  State<FaultReportDialog> createState() => _FaultReportDialogState();

  static Future<bool?> show(
    BuildContext context,
    Map<String, dynamic> faultReport,
    List<Map<String, dynamic>> artisanData,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          FaultReportDialog(faultReport: faultReport, artisanData: artisanData),
    );
  }
}

class _FaultReportDialogState extends State<FaultReportDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final role = AppManager().getRole();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isEnable = true;
  bool isUpdateStatus = false;
  bool isShowButton = false;
  String? status;

  Map<String, dynamic>? selectedArtisan;

  String? oldComment;
  DateTime? _startDate;
  DateTime? _endDate;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeData();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeData() {
    setState(() {
      // Parse start date
      if (widget.faultReport["startDate"] != null) {
        _startDate = parseDate(widget.faultReport["startDate"]);
      }

      // Parse end date
      if (widget.faultReport["endDate"] != null) {
        _endDate = parseDate(widget.faultReport["endDate"]);
      }

      // Set selected artisan
      if (widget.faultReport["artisan_id"] != null) {
        isEnable = false;

        selectedArtisan = widget.artisanData.firstWhere(
          (a) => a["id"] == widget.faultReport["artisan_id"],
          orElse: () => {},
        );
        isUpdateStatus =
            selectedArtisan!.isNotEmpty &&
            _endDate != null &&
            _startDate != null;

        isShowButton = widget.faultReport['status'] == "Cancelled" ||
            widget.faultReport['status'] == "Completed";
      }

      if (widget.faultReport["updates"] != null &&
          widget.faultReport["updates"].isNotEmpty) {
        final updatesText = (widget.faultReport["updates"] as List)
            .map((u) => u["message"])
            .join("\n");

        _notesController.text = updatesText;
        oldComment = updatesText;
      }

    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
      showError('Please select start date first', context);
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _assignTask(String taskType) async {
    setState(() {
      status = taskType;
    });
    // Validation
    if (selectedArtisan == null || selectedArtisan!.isEmpty) {
      showError('Please select an artisan', context);
      return;
    }
    if (_startDate == null) {
      showError('Please select start date', context);
      return;
    }
    if (_endDate == null) {
      showError('Please select end date', context);
      return;
    }

    final duration = _endDate!.difference(_startDate!).inDays + 1;

    if (!mounted) return;
    LoadingScreen.show(context, message: 'Processing, Please wait...');

    try {
      int? companyId = AppManager().loginResponse["user"]["company"]["id"];

      final response = await ApiService().put(
        'issues/${widget.faultReport['id']}',
        {
          "company_id": companyId,
          "artisan_id": selectedArtisan?["id"],
          "status": status,
          "progress": status == "assigned" ? 40 : 100,
          "start_date": formatForLaravel(_startDate!),
          "end_date": formatForLaravel(_endDate!),
          "update_message": _notesController.text.trim().isNotEmpty
              ? (oldComment == _notesController.text
                    ? null
                    : _notesController.text.trim())
              : null,
        },
        context,
        true,
      );

      if (!mounted) return;
      LoadingScreen.hide(context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        showCustomSnackBar(
          context,
          status == "assigned"? 'Task assigned successfully for $duration day(s)':'Task updated successfully',
          color: Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        showError(status == "assigned"?'Failed to assign task':'task updated failed', context);
      }
    } catch (e) {
      if (!mounted) return;
      LoadingScreen.hide(context);
      showError(e.toString(), context);
    }
  }

  Future<void> _updateTaskStatus(String taskType) async {
    bool? confirmed = await ConfirmationDialog.show(
      context,
      title: taskType=="cancelled"?
      'Confirm Task Cancellation':'Confirm Completion',
      message:taskType=="cancelled"?
      'Are you sure you want to cancel this task?':'Are you sure task is completed?',
    );

    if (confirmed == true) {
     String  newNote = "${ taskType=="cancelled"?'Cancelled':'Completion Approved'} by ${capitalizeFirst(AppManager().loginResponse["user"]["first_name"])} (${role})\n\n${_notesController.text}";
      setState(() {
        status = taskType;
        if (_notesController.text.trim().isNotEmpty) {
          _notesController.text = newNote;
        } else {
          _notesController.text = newNote;
        }
      });
      await _assignTask(taskType);
    }
    // if (!mounted) return;
    //
    // try {
    //
    //   LoadingScreen.show(context, message: 'Updating task status...');
    //
    //   final response = await ApiService().post(
    //     'issues/${widget.faultReport['issueID']}/update',
    //     {
    //       "update_message":
    //           'Confirmed by ${capitalizeFirst(AppManager().loginResponse["user"]["first_name"])} ($role)',
    //       "progress": 100,
    //       "status": status,
    //     },
    //     context,
    //     true,
    //   );
    //
    //   if (!mounted) return;
    //   LoadingScreen.hide(context);
    //
    //   if (response?.statusCode == 200 || response?.statusCode == 201) {
    //     showCustomSnackBar(
    //       context,
    //       'Task updated successfully',
    //       color: Colors.green,
    //     );
    //     Navigator.pop(context, true);
    //   } else {
    //     showError('Failed to update task', context);
    //   }
    // } catch (e) {
    //   if (!mounted) return;
    //   LoadingScreen.hide(context);
    //   showError(e.toString(), context);
    // }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;

    // Get images from fault report
    final images = widget.faultReport['images'] as List? ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
            // Header
            DialogHeader(title: 'Fault Report Details'),

            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: verticalPadding),
                        buildDetailCard(
                          isMobile: isMobile,
                          verticalPadding: verticalPadding,
                          context: context,
                          issue: widget.faultReport,
                        ),

                        // Images Section
                        if (images.isNotEmpty) ...[
                          SizedBox(height: verticalPadding * 2),
                          buildSectionTitle(
                            'Attached Images',
                            Icons.photo_library,
                          ),
                          SizedBox(height: verticalPadding),
                          buildImagesGrid(images, context),
                        ],

                        SizedBox(height: verticalPadding * 2),

                        // Assignment Section
                        buildSectionTitle(
                          'Assignment Details',
                          Icons.assignment_ind,
                        ),
                        SizedBox(height: verticalPadding),

                        // Artisan Selection
                        SizedBox(
                          height: 65,
                          child: CustomDropdown(
                            label: 'Assigned Artisan',
                            icon: Icons.perm_contact_cal,
                            items: widget.artisanData,
                            value: selectedArtisan,
                            displayText: (item) =>
                                "${item['fullname']} - ${item['skill']}",
                            onSelected: (item) {
                              setState(() {
                                selectedArtisan = item;
                              });
                            },
                          ),
                        ),

                        SizedBox(height: verticalPadding),

                        // Date Selection
                        Row(
                          children: [
                            Expanded(
                              child: buildDateSelector(
                                label: 'Start Date',
                                date: _startDate,
                                onTap: _selectStartDate,
                                icon: Icons.calendar_today,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildDateSelector(
                                label: 'End Date',
                                date: _endDate,
                                onTap: _selectEndDate,
                                icon: Icons.event,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: verticalPadding),

                        // Duration Display
                        if (_startDate != null && _endDate != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Duration: ${_endDate!.difference(_startDate!).inDays + 1} day(s)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: verticalPadding),

                        // Additional Notes
                        buildField(
                          controller: _notesController,
                          label: 'Additional Notes (Optional)',
                          icon: Icons.note_outlined,
                          newMaxLines: 3,
                          isEnable: isEnable,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer Buttons
            DialogBottomNavigator(
              child:
              isShowButton?
              SizedBox():
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: isUpdateStatus ? 'Close' : 'Cancel',
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () => Navigator.pop(context, false),
                  ),

                  if (isUpdateStatus)
                    CustomButton(
                      text: "Cancel Task",
                      icon: Icons.thumb_down_alt,
                      color: Colors.orange,
                      onPressed: () {
                        _updateTaskStatus("cancelled");
                      },
                    ),

                  CustomButton(
                    text: isUpdateStatus ? "Task Completed" : 'Assign Task',
                    icon: isUpdateStatus
                        ? Icons.thumb_up_alt
                        : Icons.check_circle,
                    color: Colors.green,
                    onPressed: () {
                      if (isUpdateStatus) {
                        _updateTaskStatus("completed");
                      } else {
                        _assignTask("assigned");
                      }
                    },
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
