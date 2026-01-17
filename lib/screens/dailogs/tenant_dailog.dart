import 'package:flutter/material.dart' hide required;
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import 'package:http/http.dart' as http;
import '../../providers/app_Manager.dart';
import '../../providers/constants.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/date_card.dart';
import '../../widgets/loading.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/textform.dart';

class TenantDialog extends StatefulWidget {
  final Map<String, dynamic>? data;

  const TenantDialog({Key? key, this.data}) : super(key: key);

  /// ✅ Helper to show dialog (Add / Edit)
  static Future<bool?> show(
      BuildContext context, {
        Map<String, dynamic>? data,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TenantDialog(data: data),
    );
  }

  @override
  State<TenantDialog> createState() => TenantDialogState();
}

class TenantDialogState extends State<TenantDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int selectedApartmentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _otherNamesController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _apartmentController;
  late TextEditingController _roomNumberController;
  late TextEditingController occupationController;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? selectedApartment;
  Map<String, dynamic>? selectedRoom;

  // ✅ FIXED: Safe null check
  bool get isEdit => widget.data != null && widget.data!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    final data = widget.data;

    _firstNameController = TextEditingController(text: data?['fullname'] ?? '');
    _otherNamesController = TextEditingController(text: data?['last_name'] ?? '');
    _phoneController = TextEditingController(text: data?['contact'] ?? '');
    _emailController = TextEditingController(text: data?['email'] ?? '');
    _apartmentController = TextEditingController(text: '');
    _roomNumberController = TextEditingController(text: '');
    occupationController = TextEditingController(text: data?['occupation'] ?? '');

    // Dates
    _startDate = data?['move_in_date'] != null
        ? DateTime.parse(data!['move_in_date'])
        : null;

    _endDate = data?['lease_end_date'] != null
        ? DateTime.parse(data!['lease_end_date'])
        : null;

    /// ✅ AUTO-SELECT apartment + room
    if (data != null) {
      for (final apartment in selectedApartmentRoomList) {
        final rooms = List<Map<String, dynamic>>.from(apartment['rooms'] ?? []);

        final room = rooms.firstWhere(
              (r) => r['id'] == data['room_id'],
          orElse: () => {},
        );

        if (room.isNotEmpty) {
          selectedApartment = apartment;
          selectedRoom = room;
          break;
        }
      }
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _otherNamesController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _roomNumberController.dispose();
    _apartmentController.dispose();
    occupationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate all required fields
      if (_firstNameController.text.isEmpty) {
        _showError('Please enter first name');
        return;
      }
      if (_otherNamesController.text.isEmpty) {
        _showError('Please enter other names');
        return;
      }
      if (_phoneController.text.isEmpty) {
        _showError('Please enter phone number');
        return;
      }
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        _showError('Please enter a valid email');
        return;
      }
      if (selectedApartment == null || selectedApartment!.isEmpty) {
        _showError('Please select apartment');
        return;
      }
      if (selectedRoom == null || selectedRoom!.isEmpty) {
        _showError('Please select room');
        return;
      }
      if (occupationController.text.isEmpty) {
        _showError('Please enter occupation');
        return;
      }
      if (_startDate == null) {
        _showError('Please select move-in date');
        return;
      }
      if (_endDate == null) {
        _showError('Please select lease end date');
        return;
      }

      try {
        LoadingScreen.show(context, message: 'Processing, Please wait...');
        int? companyId = AppManager().loginResponse["user"]["company_id"];
        final http.Response? response;


      final payload = {
        "first_name": capitalizeFirst(_firstNameController.text.trim()),
        "last_name": capitalizeFirst(_otherNamesController.text.trim()),
        "company_id": companyId ?? 0,
        "email": _emailController.text.trim(),
        "contact": _phoneController.text.trim(),
        "password": _phoneController.text.trim(),
        "room_id": selectedRoom?['id'] ?? 0,
        "occupation": capitalizeFirst(occupationController.text.trim()),
        "move_in_date": formatForLaravel(_startDate!),
        "lease_end_date": formatForLaravel(_endDate!),
      };

      if (isEdit) {
        response = await ApiService().put(
          'tenants/${widget.data!['id']}',
          payload,
          context,
          true,
        );
      } else {
        response = await ApiService().post(
          'tenants',
          payload,
          context,
          true,
        );
      }

      LoadingScreen.hide(context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        Navigator.of(context).pop(true);
        showCustomSnackBar(
          context,
          isEdit ? 'Tenant updated successfully' : 'Tenant added successfully',
          color: Colors.green,
        );
      } else {
        _showError('Failed to ${isEdit ? 'update' : 'add'} tenant');
      }
      } catch (e) {
       // LoadingScreen.hide(context);
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    showCustomSnackBar(context, message, color: Colors.red);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        setError('move_in_date', null);
      });
    }
  }

  void _clearForm() {
    Navigator.of(context).pop();
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      _showError('Please select start date first');
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: isMobile ? size.height * 0.85 : size.height * 0.55,
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
            DialogHeader(title: isEdit ? 'Edit Tenant' : ' New Tenant'),

            // Form Content
            Expanded(
              child: _buildTenantInfoPage(
                isMobile,
                horizontalPadding,
                verticalPadding,
              ),
            ),

            // Navigation Buttons
            DialogBottomNavigator(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: _clearForm,
                  ),
                  CustomButton(
                    text: isEdit ? 'Update' : 'Save',
                    icon: Icons.check,
                    color: Colors.green,
                    onPressed: _submitForm,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTenantInfoPage(
      bool isMobile,
      double horizontalPadding,
      double verticalPadding,
      ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isEdit
                  ? buildField(
                controller: _firstNameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                isEnable: false,
              )
                  : Row(
                children: [
                  Expanded(
                    child: buildField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      onChangeAction: (v) =>
                          setError('first_name', required(v, 'First name')),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: buildField(
                      controller: _otherNamesController,
                      label: 'Other Names',
                      icon: Icons.person_outline,
                      onChangeAction: (v) =>
                          setError('other_names', required(v, 'Other names')),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalPadding),
              Row(
                children: [
                  Expanded(
                    child: buildField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChangeAction: (v) => setError('email', emailValidator(v)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: buildField(
                      controller: occupationController,
                      label: 'Occupation',
                      icon: Icons.business_center_sharp,
                      onChangeAction: (v) =>
                          setError('occupation', required(v, 'Occupation')),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalPadding),
              buildField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                newMaxLength: 10,
                keyboardType: TextInputType.phone,
                onChangeAction: (v) =>
                    setError('contact', required(v, 'Phone number')),
              ),
              SizedBox(height: verticalPadding),
              Row(
                children: [
                  Expanded(
                    child: CustomDropdown(
                      label: 'Apartment Name',
                      icon: Icons.apartment_outlined,
                      items: List<Map<String, dynamic>>.from(
                          selectedApartmentRoomList),
                      value: selectedApartment,
                      displayText: (item) => item['name'],
                      onSelected: (item) {
                        if (item["rooms"] != null && item["rooms"].isNotEmpty) {
                          setState(() {
                            selectedApartment = item;
                            selectedRoom = null;
                            setError('apartment', null);
                          });
                        } else {
                          showCustomSnackBar(
                            context,
                            "Sorry, no rooms are assigned to this apartment",
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDropdown(
                      label: 'Room Number',
                      icon: Icons.roofing,
                      // Filter the items here 👇
                      items: selectedApartment != null
                          ? List<Map<String, dynamic>>.from(selectedApartment!['rooms'] ?? [])
                          .where((room) => room['status'] == 'vacant') // Only keep vacant rooms
                          .toList()
                          : [],
                      value: selectedRoom,
                      displayText: (item) => "${item['room_number']} (Vacant)", // Optional: cleaner label
                      onSelected: (item) {
                        // Since the list is filtered, we know the item is vacant
                        setState(() {
                          selectedRoom = item;
                          setError('room', null);
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalPadding),
              Row(
                children: [
                  Expanded(
                    child: buildDateSelector(
                      label: 'Move in Date',
                      date: _startDate,
                      onTap: _selectStartDate,
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildDateSelector(
                      label: 'Lease end Date',
                      date: _endDate,
                      onTap: _selectEndDate,
                      icon: Icons.event,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}