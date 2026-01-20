import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fms_app/screens/login_screen.dart';
import '../utils/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/btn.dart';
import '../widgets/loading.dart';
import '../widgets/textform.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _companyFormKey = GlobalKey<FormState>();
  final _userFormKey = GlobalKey<FormState>();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool isLoading = false;
  Uint8List? _companyLogo;


  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Company Controllers
  final _companyNameController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyCityController = TextEditingController();
  final _companyTownController = TextEditingController();
  final _companyPostalController = TextEditingController();
  final _companySenderIDController = TextEditingController();

  // Admin Controllers
  final _firstNameController = TextEditingController();
  final _otherNamesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  // Test API connection on screen load


  @override
  void dispose() {
    _animationController.dispose();
    _companyNameController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    _companyAddressController.dispose();
    _companyCityController.dispose();
    _companyTownController.dispose();
    _companyPostalController.dispose();
    _companySenderIDController.dispose();
    _firstNameController.dispose();
    _otherNamesController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cPasswordController.dispose();
    super.dispose();
  }

  // ===================== IMAGE PICKER =====================
  Future<void> _pickLogo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // important for web
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _companyLogo = result.files.single.bytes!;
      });
    }
  }

  // ===================== SUBMIT =====================
  Future<void> _submitData() async {
    if (!_companyFormKey.currentState!.validate() ||
        !_userFormKey.currentState!.validate()) {
      print('⚠️ Validation Error: One of the forms is invalid.');
      return;
    }

    if (_passwordController.text != _cPasswordController.text) {
      showCustomSnackBar(context, 'Passwords do not match', color: Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      LoadingScreen.show(context, message: 'Registering Company...');

      // 1. Log the Data Payload
      final body = {
        "company[name]": _companyNameController.text.trim(),
        "company[email]": _companyEmailController.text.trim(),
        "company[phone]": _companyPhoneController.text.trim(),
        "company[address]": _companyAddressController.text.trim(),
        "company[city]": _companyCityController.text.trim(),
        "company[town]": _companyTownController.text.trim(),
        "company[postal_code]": _companyPostalController.text.trim(),
        "company[sender_id]": _companySenderIDController.text.trim(),
        "admin[first_name]": _firstNameController.text.trim(),
        "admin[last_name]": _otherNamesController.text.trim(),
        "admin[email]": _emailController.text.trim(),
        "admin[password]": _passwordController.text,
        "admin[contact]": _phoneController.text.trim(),
      };

      print('-------------------------------------------');
      print('🚀 [DEBUG] STARTING REGISTRATION REQUEST');
      print('📂 Payload: ${jsonEncode(body)}');
      print('🖼️ Logo Selected: ${_companyLogo != null ? "YES (${_companyLogo!.length} bytes)" : "NO"}');

      // 2. Execute Request
      final response = await ApiService().multipartPost(
        endpoint: 'companies/register',
        fields: body,
        fileBytes: _companyLogo,
        fileName: _companyLogo != null ? 'company_logo.png' : null,
        fileFieldName: 'logo',
      );

      // 3. Log the Response status
      if (response != null) {
       // print('📥 [DEBUG] RESPONSE RECEIVED');
       // print('🔢 Status Code: ${response.statusCode}');
        print('📄 Body: ${response.body}');

        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ [DEBUG] REGISTRATION SUCCESSFUL');
          if (mounted) LoadingScreen.hide(context);

          showCustomSnackBar(
            context,
            responseData['message'] ?? 'Company registered successfully!',
            color: Colors.green,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
        //  print('❌ [DEBUG] SERVER RETURNED SUCCESS: FALSE');
          if (mounted) LoadingScreen.hide(context);

          // Detailed error logging for validation errors
          if (responseData['errors'] != null) {
            print('❗ Validation Errors: ${responseData['errors']}');
          }

          showCustomSnackBar(
            context,
            responseData['message'] ?? 'Registration failed',
            color: Colors.redAccent,
          );
        }
      } else {
      //  print('🚫 [DEBUG] RESPONSE WAS NULL (ApiService might have caught an error)');
      }
    } catch (e) {
     // print('💥 [DEBUG] CRITICAL ERROR IN SUBMIT: $e');
      if (mounted) {
        LoadingScreen.hide(context);
        showCustomSnackBar(context, e.toString(), color: Colors.redAccent);
      }
    } finally {
     // print('🏁 [DEBUG] REGISTRATION PROCESS FINISHED');
      print('-------------------------------------------');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = size.width * 0.05;
    final verticalPadding = size.height * 0.02;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isMobile
                  ? horizontalPadding * 2.0
                  : horizontalPadding * 5.0,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding * 0.3,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                bottom: BorderSide(
                  color:
                  Theme.of(context).scaffoldBackgroundColor ==
                      Colors.grey.shade50
                      ? Colors.grey.shade200
                      : Colors.transparent,
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Create Company Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Create an account for your company',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: verticalPadding),

                  // Company Info
                  buildCompanyInfoPage(
                    isMobile,
                    verticalPadding,
                    horizontalPadding,
                  ),
                  SizedBox(height: verticalPadding * 1),

                  // Admin/User Info
                  buildUserInfoPage(
                    isMobile,
                    verticalPadding,
                    horizontalPadding,
                  ),
                  SizedBox(height: verticalPadding * 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: 'Cancel',
                        icon: Icons.close,
                        color: Colors.redAccent,
                        onPressed: (){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                      ),
                      CustomButton(
                        text: 'Submit',
                        icon: Icons.check,
                        color: Colors.green.shade400,
                        onPressed: isLoading ? null : _submitData,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCompanyInfoPage(bool isMobile, double vPadding, double hPadding) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _companyFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.camera_alt, size: 30, color: Colors.grey, ),
              label: Text(
                _companyLogo == null ? 'Upload Company Logo' : 'Change Logo',
                style: TextStyle(color: Colors.grey,fontSize: 12),
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                side: MaterialStateProperty.all(
                  BorderSide(color: Colors.grey.shade400),
                ),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            if (_companyLogo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.memory(_companyLogo!, height: 80),
              ),
            SizedBox(height: vPadding),

            Row(
              children: [
                Expanded(
                  child:  buildField(
                    controller: _companyNameController,
                    label: 'Company Name',
                    icon: Icons.business_outlined,
                  ),
                ),
                SizedBox(width: hPadding * 0.22),
                Expanded(
                  child: buildField(
                    controller: _companyEmailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            SizedBox(height: vPadding),
            Row(
              children: [
                Expanded(
                  child: buildField(
                    controller: _companySenderIDController,
                    label: 'SMS SenderID',
                    icon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.text,
                    newMaxLength: 11
                  ),
                ),
                SizedBox(width: hPadding * 0.22),
                Expanded(
                  child: buildField(
                    controller: _companyPostalController,
                    label: 'Postal Address',
                    icon: Icons.pin_drop_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: vPadding),
            Row(
              children: [
                Expanded(
                  child: buildField(
                    controller: _companyAddressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                SizedBox(width: hPadding * 0.22),
                Expanded(
                  child: buildField(
                    controller: _companyPhoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.number,
                    newMaxLength: 10
                  ),
                ),
              ],
            ),
            SizedBox(height: vPadding),
            Row(
              children: [
                Expanded(
                  child: buildField(
                    controller: _companyCityController,
                    label: 'City',
                    icon: Icons.location_city_rounded,
                  ),
                ),
                SizedBox(width: hPadding * 0.22),
                Expanded(
                  child: buildField(
                    controller: _companyTownController,
                    label: 'Town',
                    icon: Icons.real_estate_agent_outlined,
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget buildUserInfoPage(bool isMobile, double vPadding, double hPadding) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _userFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Administrator Details',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: vPadding),
            Row(
              children: [
                Expanded(
                  child: buildField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline,
                  ),
                ),
                SizedBox(width: hPadding * 0.22),
                Expanded(
                  child: buildField(
                    controller: _otherNamesController,
                    label: 'Other Names',
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),
            SizedBox(height: vPadding),
            Row(
              children: [
                Expanded(
                  child: buildField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.number,
                      newMaxLength: 10
                  ),
                ),
                SizedBox(width: hPadding * 0.22),
                Expanded(
                  child: buildField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            SizedBox(height: vPadding),
            Row(
              children: [
                Expanded(
                  child: passwordField(
                    controller: _passwordController,
                    label: 'Password',
                    isHidden: _isPasswordHidden,
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.visiblePassword,
                    onToggle: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                ),
                SizedBox(width: hPadding * 0.22),
                Expanded(
                  child: passwordField(
                    controller: _cPasswordController,
                    label: 'Confirm Password',
                    isHidden: _isConfirmPasswordHidden,
                    icon: Icons.lock_clock_outlined,
                    keyboardType: TextInputType.visiblePassword,
                    onToggle: () {
                      setState(() {
                        _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}