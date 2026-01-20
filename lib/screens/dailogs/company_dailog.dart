import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fms_app/providers/app_Manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/loading.dart';
import '../../widgets/textform.dart';
import '../../components/dailog_widgets/header.dart';

class CompanySettingsDialog extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const CompanySettingsDialog({super.key, required this.companyData});

  @override
  State<CompanySettingsDialog> createState() => _CompanySettingsDialogState();

  static Future<bool?> show(BuildContext context, Map<String, dynamic> data) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CompanySettingsDialog(companyData: data),
    );
  }
}

class _CompanySettingsDialogState extends State<CompanySettingsDialog> {
  final _formKey = GlobalKey<FormState>();

  // Image Picking Variables
  Uint8List? _logoBytes;
  XFile? _pickedFile;
  bool _isLoadingLogo = false;
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _townController;
  late TextEditingController _postalController;
  late TextEditingController _senderIDController;

  @override
  void initState() {
    super.initState();
    final company = widget.companyData;
    _nameController = TextEditingController(text: company['name'] ?? '');
    _phoneController = TextEditingController(text: company['phone'] ?? '');
    _emailController = TextEditingController(text: company['email'] ?? '');
    _addressController = TextEditingController(text: company['address'] ?? '');
    _cityController = TextEditingController(text: company['city'] ?? '');
    _townController = TextEditingController(text: company['town'] ?? '');
    _postalController = TextEditingController(text: company['postal_code'] ?? '');
    _senderIDController = TextEditingController(text: company['sender_id'] ?? '');
    _loadInitialLogo(company['logo']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _townController.dispose();
    _postalController.dispose();
    _senderIDController.dispose();
    super.dispose();
  }


  Future<void> _loadInitialLogo(String? rawPath) async {
    if (rawPath == null || rawPath.isEmpty) return;

    setState(() => _isLoadingLogo = true);
    try {
      // Call your proxy endpoint
      final response = await ApiService().get('company-logo-proxy?path=$rawPath',context);
      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String base64String = data['data'].toString().split(',').last;
        setState(() {
          _logoBytes = base64Decode(base64String);
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading initial logo: $e');
    } finally {
      setState(() => _isLoadingLogo = false);
    }
  }
  /// 📸 PICK LOGO FUNCTION
  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500, // Limit size for faster upload
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedFile = image;
        _logoBytes = bytes;
      });
    }
  }

  /// 📤 SUBMIT FORM (MULTIPART)
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;


    try {
      if (mounted) LoadingScreen.show(context, message: 'Updating company profile...');

      int? companyId = widget.companyData['id'];
      String? token = AppManager().getLoginToken();

      // Create Multipart Request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiService.baseUrl}/companies/$companyId/update'),
      );

      // Add Headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add Text Fields
      request.fields.addAll({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
        "city": _cityController.text.trim(),
        "town": _townController.text.trim(),
        "postal_code": _postalController.text.trim(),
        "sender_id": _senderIDController.text.trim(),
      });

      // Add Logo File if picked
      if (_pickedFile != null && _logoBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'logo',
            _logoBytes!,
            filename: _pickedFile!.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (mounted)  LoadingScreen.hide(context);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Update local AppManager data so UI refreshes
        AppManager().loginResponse["user"]["company"] = responseData['data'];

        showCustomSnackBar(context, 'Company updated successfully!', color: Colors.green);
        Navigator.of(context).pop(true);
      } else {
        final errorData = jsonDecode(response.body);
        showCustomSnackBar(context, errorData['message'] ?? 'Update failed', color: Colors.red);
      }
    } catch (e) {
      if (mounted) LoadingScreen.hide(context);
      showCustomSnackBar(context, 'An error occurred: $e', color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DialogHeader(title: 'Edit Company Profile'),

             SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildLogoPicker(),
                      const SizedBox(height: 24),

                      buildField(
                        controller: _nameController,
                        label: 'Company Name',
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: buildField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              newMaxLength: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: buildField(
                              controller: _senderIDController,
                              label: 'SMS Sender ID',
                              icon: Icons.message_outlined,
                              newMaxLength: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildField(
                              controller: _postalController,
                              label: 'Postal Code',
                              icon: Icons.local_post_office_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      buildField(
                        controller: _addressController,
                        label: 'Street Address',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: buildField(
                              controller: _cityController,
                              label: 'City',
                              icon: Icons.location_city_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildField(
                              controller: _townController,
                              label: 'Town',
                              icon: Icons.map_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),


            _buildFooterButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPicker() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.blue.shade100, width: 2),
                image: _logoBytes != null
                    ? DecorationImage(image: MemoryImage(_logoBytes!), fit: BoxFit.cover)
                    : (widget.companyData['logo_url'] != null
                    ? DecorationImage(image: NetworkImage(widget.companyData['logo_url']), fit: BoxFit.cover)
                    : null),
              ),
              child: _logoBytes == null && widget.companyData['logo_url'] == null
                  ? const Icon(Icons.business, size: 40, color: Colors.grey)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text("Company Logo", style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFooterButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomButton(
            text: 'Cancel',
            icon: Icons.close,
            color: Colors.redAccent,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          CustomButton(
            text: 'Save Changes',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}