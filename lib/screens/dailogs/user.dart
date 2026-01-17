import 'package:flutter/material.dart';
import 'package:fms_app/providers/app_Manager.dart';
import 'package:http/http.dart' as http;

import '../../components/dailog_widgets/bottom_bar.dart';
import '../../components/dailog_widgets/header.dart';
import '../../providers/constants.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/loading.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/textform.dart';

class UserDialog extends StatefulWidget {
  final Map<String, dynamic>? selectedArtisan;

  const UserDialog({super.key, this.selectedArtisan});

  @override
  State<UserDialog> createState() => _UserDialogState();

  static Future<void> show(
      BuildContext context,
      Map<String, dynamic>? selectedArtisanItem,
      ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserDialog(selectedArtisan: selectedArtisanItem),
    );
  }
}

class _UserDialogState extends State<UserDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  final _firstNameController = TextEditingController();
  final _otherNamesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _gpsController = TextEditingController();
  final roleController = TextEditingController();

  Map<String, dynamic> selectedRole = {"status":"staff", "role":"Staff"};

  // Helper getter to check if editing
  bool get isEditMode => widget.selectedArtisan != null && widget.selectedArtisan!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    if (widget.selectedArtisan != null && widget.selectedArtisan!.isNotEmpty) {
      final artisan = widget.selectedArtisan!;
      _firstNameController.text = artisan['first_name'] ?? '';
      _otherNamesController.text = artisan['last_name'] ?? '';
      _phoneController.text = artisan['contact'] ?? '';
      _emailController.text = artisan['email'] ?? '';
      _locationController.text = artisan['location'] ?? '';
      roleController.text = artisan['role'] ?? '';

      // Find matching role from roleList
      final matchingRole = roleList.firstWhere(
            (role) => role['status'] == artisan['role'],
        orElse: () => {"status":"staff", "role":"Staff"},
      );
      selectedRole = matchingRole;
    }

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
    _pageController.dispose();
    _animationController.dispose();
    _firstNameController.dispose();
    _otherNamesController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _gpsController.dispose();
    roleController.dispose();
    super.dispose();
  }

  bool _validateArtisanForm() {
    if (_firstNameController.text.isEmpty) {
      _showError('Please enter first name');
      return false;
    }
    if (_otherNamesController.text.isEmpty) {
      _showError('Please enter other names');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showError('Please enter phone number');
      return false;
    }
    if (!_emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return false;
    }
    if (roleController.text.isEmpty) {
      _showError('Please select a role');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    showCustomSnackBar(context, message, color: Colors.red);
  }

  Future<void> submitForm({required bool isEdit}) async {
    try {
      LoadingScreen.show(context, message: 'Processing, please wait...');

      final int userId = AppManager().loginResponse["user"]["id"];
      http.Response? response;

      if (isEdit) {
        response = await ApiService().put(
          'users/$userId',
          {
            "first_name": capitalizeFirst(_firstNameController.text.trim()),
            "last_name": capitalizeFirst(_otherNamesController.text.trim()),
            "email": _emailController.text.trim(),
            "contact": _phoneController.text.trim(),
            "role": selectedRole['status'], // Use status field for API
          },
          context,
          true,
        );
      } else {
        response = await ApiService().post(
          'users',
          {
            "first_name": capitalizeFirst(_firstNameController.text.trim()),
            "last_name": capitalizeFirst(_otherNamesController.text.trim()),
            "email": _emailController.text.trim(),
            "contact": _phoneController.text.trim(),
            "password": _phoneController.text.trim(),
            "role": selectedRole['status'], // Use status field for API
          },
          context,
          true,
        );
      }

      LoadingScreen.hide(context);

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        showCustomSnackBar(
          context,
          isEdit
              ? 'User updated successfully'
              : 'User added successfully',
          color: Colors.green,
        );
        Navigator.of(context).pop(true);
      } else {
        _showError('Operation failed');
      }
    } catch (e) {
      LoadingScreen.hide(context);
      _showError(e.toString());
    }
  }

  final List<Map<String, dynamic>> roleList = [
    {"status":"staff", "role":"Staff"},
    {"status":"admin", "role":"Admin"},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        height: 450,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            DialogHeader(
              title: isEditMode ? 'Edit Staff' : 'Add New Staff',
            ),
            Expanded(child: _buildForm(isMobile)),
            DialogBottomNavigator(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CustomButton(
                    text: isEditMode ? 'Update' : 'Save',
                    icon: Icons.check,
                    color: Colors.green,
                    onPressed: () {
                      if (_validateArtisanForm()) {
                        submitForm(isEdit: isEditMode);
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

                    buildField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person,
                    ),

              const SizedBox(height: 12),
                  buildField(
                      controller: _otherNamesController,
                      label: 'Other Names',
                      icon: Icons.person_outline,

                  ),

              const SizedBox(height: 12),
              buildField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                    ),
              const SizedBox(height: 12),
                 buildField(
                      controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone,
                      newMaxLength: 10,
                    ),


              const SizedBox(height: 12),
              _buildRoleDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return SizedBox(
      height: 65,
      child: CustomDropdown(
        label: 'User Role',
        icon: Icons.perm_contact_cal,
        items: roleList,
        value: selectedRole,
        displayText: (item) => item['role'],
        onSelected: (item) {
          setState(() {
            selectedRole = item;
            roleController.text = item['role'] ?? '';
          });
        },
      ),
    );
  }
}