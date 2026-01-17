import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import 'package:fms_app/providers/app_Manager.dart';
import 'package:http/http.dart' as http;
import '../../providers/constants.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/loading.dart';
import '../../widgets/textform.dart';

class ArtisanDialog extends StatefulWidget {
  final Map<String, dynamic>? selectedArtisan;
  const ArtisanDialog({super.key, this.selectedArtisan});

  @override
  State<ArtisanDialog> createState() => _ArtisanDialogState();

  static Future<bool?> show(
    BuildContext context,
    Map<String, dynamic>? selectedArtisanItem,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ArtisanDialog(selectedArtisan: selectedArtisanItem),
    );
  }
}

class _ArtisanDialogState extends State<ArtisanDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Artisan Controllers
  final _firstNameController = TextEditingController();
  final _otherNamesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  // final _gpsController = TextEditingController();
  final _skillController = TextEditingController();

  // Next of Kin Controllers
  final _nokFullNameController = TextEditingController();
  final _nokPhoneController = TextEditingController();
  final _nokLocationController = TextEditingController();
  final _nokRelationshipController = TextEditingController();
  String? selectedRoomId;

  @override
  void initState() {
    super.initState();

    if (widget.selectedArtisan != null) {
      final artisan = widget.selectedArtisan!;

      _firstNameController.text = artisan['first_name'] ?? '';
      _otherNamesController.text = artisan['last_name'] ?? '';
      _phoneController.text = artisan['contact'] ?? '';
      _emailController.text = artisan['email'] ?? '';
      _locationController.text = artisan['location'] ?? '';
      _skillController.text = artisan['skill'] ?? '';

      _nokFullNameController.text = artisan['nok_full_name'] ?? '';
      _nokPhoneController.text = artisan['nok_phone'] ?? '';
      _nokLocationController.text = artisan['nok_location'] ?? '';
      _nokRelationshipController.text = artisan['nok_relationship'] ?? '';

      selectedRoomId = artisan['status']?.toString() ?? '1';
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
    // _gpsController.dispose();
    _skillController.dispose();
    _nokFullNameController.dispose();
    _nokPhoneController.dispose();
    _nokLocationController.dispose();
    _nokRelationshipController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (!_validateArtisanForm()) return;
    }

    if (_currentPage < 1) {
      _animationController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _animationController.reset();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    }
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
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return false;
    }
    if (_locationController.text.isEmpty) {
      _showError('Please enter location');
      return false;
    }
    if (_skillController.text.isEmpty) {
      _showError('Please enter skill/trade');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    showCustomSnackBar(context, message, color: Colors.red);
  }

  void submitForm({required bool isEdit}) async {
    if (_nokFullNameController.text.isEmpty) {
      _showError('Please enter next of kin full name');
      return;
    }
    if (_nokPhoneController.text.isEmpty) {
      _showError('Please enter next of kin phone number');
      return;
    }
    if (_nokLocationController.text.isEmpty) {
      _showError('Please enter next of kin location');
      return;
    }
    if (_nokRelationshipController.text.isEmpty) {
      _showError('Please enter relationship');
      return;
    }

    try {
      LoadingScreen.show(context, message: 'Processing, Please wait...');
      int? companyId = AppManager().loginResponse["user"]["company_id"];
      final http.Response? response;
      widget.selectedArtisan!.isNotEmpty
          ? response = await ApiService().put(
              'artisans',
              {
                "first_name": capitalizeFirst(_firstNameController.text.trim()),
                "last_name": capitalizeFirst(_otherNamesController.text.trim()),
                "company_id": companyId ?? 0,
                "email": _emailController.text.trim(),
                "contact": _phoneController.text.trim(),
                "role": "artisan",
                "skill": capitalizeFirst(_skillController.text.trim()),
                "nok_full_name": capitalizeFirst(
                  _nokFullNameController.text.trim(),
                ),
                "nok_phone": _nokPhoneController.text.trim(),
                "nok_location": _nokLocationController.text.trim(),
                "nok_relationship": _nokRelationshipController.text
                    .trim(), // ✅ FIXED
              },
              context,
              true,
            )
          : response = await ApiService().post(
              'artisans',
              {
                "first_name": capitalizeFirst(_firstNameController.text.trim()),
                "last_name": capitalizeFirst(_otherNamesController.text.trim()),
                "company_id": companyId ?? 0,
                "email": _emailController.text.trim(),
                "contact": _phoneController.text.trim(),
                "password": _phoneController.text.trim(),
                "role": "artisan",
                "skill": capitalizeFirst(_skillController.text.trim()),
                "nok_full_name": capitalizeFirst(
                  _nokFullNameController.text.trim(),
                ),
                "nok_phone": _nokPhoneController.text.trim(),
                "nok_location": _nokLocationController.text.trim(),
                "nok_relationship": _nokRelationshipController.text
                    .trim(), // ✅ FIXED
              },
              context,
              true,
            );

      LoadingScreen.hide(context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        showCustomSnackBar(
          context,
          'Artisan added successfully',
          color: Colors.green,
        );
        Navigator.of(context).pop(true); // return success
      } else {
        _showError('Failed to add artisan');
      }
    } catch (e) {
      LoadingScreen.hide(context);
      _showError(e.toString());
    }
  }

  void _clearForm() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;
    if (widget.selectedArtisan != null) {
      final artisan = widget.selectedArtisan!;

      selectedRoomId = artisan['status'] == 1 || artisan['status'] == '1'
          ? 'Active'
          : artisan['status'] == 0 || artisan['status'] == '0'
          ? 'Inactive'
          : artisan['status']?.toString();
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: isMobile ? size.height * 0.85 : size.height * 0.65,
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
            DialogHeader(
              title: widget.selectedArtisan == null
                  ? 'Add New Artisan'
                  : 'Edit Artisan',
            ),
            // Progress Indicator
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: _buildProgressIndicator(
                isMobile,
                horizontalPadding,
                verticalPadding,
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildArtisanInfoPage(
                    isMobile,
                    horizontalPadding,
                    verticalPadding,
                  ),
                  _buildNextOfKinPage(
                    isMobile,
                    horizontalPadding,
                    verticalPadding,
                  ),
                ],
              ),
            ),

            // Navigation Buttons
            DialogBottomNavigator(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    CustomButton(
                      text: 'Previous',
                      icon: Icons.arrow_back,
                      color: Colors.grey,
                      onPressed: _previousPage,
                    )
                  else
                    CustomButton(
                      text: 'Cancel',
                      icon: Icons.close,
                      color: Colors.red,
                      onPressed: _clearForm,
                    ),
                  if (_currentPage < 1)
                    CustomButton(
                      text: 'Next',
                      icon: Icons.arrow_forward,
                      color: Colors.blue,
                      onPressed: _nextPage,
                    )
                  else
                    CustomButton(
                      text: widget.selectedArtisan!.isNotEmpty
                          ? "Update"
                          : 'Save',
                      icon: Icons.check,
                      color: Colors.green,
                      onPressed: () {
                        submitForm(
                          isEdit: widget.selectedArtisan!.isNotEmpty
                              ? true
                              : false,
                        );
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

  Widget _buildProgressIndicator(
    bool isMobile,
    double horizontalPadding,
    double verticalPadding,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).scaffoldBackgroundColor == Colors.grey.shade50
                ? Colors.grey.shade200
                : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStepIndicator(
              stepNumber: 1,
              title: 'Artisan Info',
              isActive: _currentPage == 0,
              isCompleted: _currentPage > 0,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: _currentPage > 0 ? Colors.green : Colors.grey.shade300,
            ),
          ),
          Expanded(
            child: _buildStepIndicator(
              stepNumber: 2,
              title: 'Next of Kin',
              isActive: _currentPage == 1,
              isCompleted: false,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
    required bool isMobile,
  }) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isActive
                ? Colors.blue
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildArtisanInfoPage(
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
              if (!isMobile)
                Row(
                  children: [
                    Expanded(
                      child: buildField(
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: buildField(
                        controller: _otherNamesController,
                        label: 'Other Names',
                        icon: Icons.person_outline,
                      ),
                    ),
                  ],
                )
              else ...[
                buildField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: verticalPadding),
                buildField(
                  controller: _otherNamesController,
                  label: 'Other Names',
                  icon: Icons.person_outline,
                ),
              ],
              SizedBox(height: verticalPadding),
              if (!isMobile)
                Row(
                  children: [
                    Expanded(
                      child: buildField(
                        controller: _skillController,
                        label: 'Skill / Trade',
                        icon: Icons.build_outlined,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: buildField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                )
              else ...[
                buildField(
                  controller: _skillController,
                  label: 'Skill / Trade',
                  icon: Icons.build_outlined,
                ),
                SizedBox(height: verticalPadding),
                buildField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
              SizedBox(height: verticalPadding),
              if (!isMobile)
                Row(
                  children: [
                    Expanded(
                      child: buildField(
                        controller: _locationController,
                        label: 'Location',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: buildField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        newMaxLength: 10,
                      ),
                    ),
                  ],
                )
              else ...[
                buildField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                ),
                SizedBox(height: verticalPadding),

              ],


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextOfKinPage(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildField(
              controller: _nokFullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
            ),
            SizedBox(height: verticalPadding),
            buildField(
              controller: _nokPhoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              newMaxLength: 10,
            ),
            SizedBox(height: verticalPadding),
            buildField(
              controller: _nokLocationController,
              label: 'Location',
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: verticalPadding),
            buildField(
              controller: _nokRelationshipController,
              label: 'Relationship',
              icon: Icons.family_restroom,
            ),
          ],
        ),
      ),
    );
  }
}
