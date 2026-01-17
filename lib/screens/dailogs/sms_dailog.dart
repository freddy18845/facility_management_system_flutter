import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/textform.dart';

class SmsDialog extends StatefulWidget {
  final List<Map<String, dynamic>>? contacts; // List of {name, number}
  final VoidCallback onSubmit;

  const SmsDialog({
    super.key,
    this.contacts,
    required this.onSubmit,
  });

  @override
  State<SmsDialog> createState() => _SmsDialogState();

  static Future<void> show(BuildContext context, {List<Map<String, dynamic>>? contacts, required VoidCallback onSubmit}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SmsDialog(contacts: contacts, onSubmit: onSubmit),
    );
  }
}

class _SmsDialogState extends State<SmsDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _customNumberController = TextEditingController();

  bool _isCustomNumber = false;
  Set<String> _selectedNumbers = {};
  int _characterCount = 0;
  final int _maxCharacters = 160;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateCharacterCount);
    if(widget.contacts!.isNotEmpty){
      _selectedNumbers = widget.contacts!
          .map((c) => c['contact'])
          .where((n) => n != null)
          .map((n) => n.toString())
          .toSet();
    }

    // If no contacts provided, default to custom number mode
    if (widget.contacts == null || widget.contacts!.isEmpty) {
      _isCustomNumber = true;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _customNumberController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _messageController.text.length;
    });
  }

  void _toggleRecipient(String number) {
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        _selectedNumbers.add(number);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedNumbers.length == widget.contacts?.length) {
        _selectedNumbers.clear();
      } else {
        _selectedNumbers = widget.contacts!.map((c) => c['number'].toString()).toSet();
      }
    });
  }

  bool _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // Validate recipients
      if (!_isCustomNumber && _selectedNumbers.isEmpty) {
        showCustomSnackBar(context,'Please select at least one recipient',color:Colors.red);
        return false;
      }

      if (_isCustomNumber && _customNumberController.text.isEmpty) {
        showCustomSnackBar(context,'Please enter a phone number',color:Colors.red);
        return false;
      }

      // Validate message
      if (_messageController.text.isEmpty) {
        showCustomSnackBar(context,'Please enter a message',color:Colors.red);
        return false;
      }

      return true;
    }
    return false;
  }

  String _getRecipientsSummary() {
    if (_isCustomNumber) {
      return _customNumberController.text;
    } else {
      return '${_selectedNumbers.length} recipient(s) selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: isMobile ? size.height * 0.85 : size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
          DialogHeader(title: 'Send SMS'),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipient Selection Toggle
                      if (widget.contacts != null && widget.contacts!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isCustomNumber = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isCustomNumber ? Colors.blue.shade700 : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Select from List',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: !_isCustomNumber ? Colors.white : Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isCustomNumber = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isCustomNumber ? Colors.blue.shade700 : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Custom Number',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _isCustomNumber ? Colors.white : Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Recipients Section
                      const Text(
                        'Recipients',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Custom Number Input
                      if (_isCustomNumber)
                        buildField(
                          controller: _customNumberController,
                          label: 'Phone Number (e.g., 0274123456)',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          newMaxLength: 10,
                        ),

                      // Contact List
                      if (!_isCustomNumber && widget.contacts != null)
                        Column(
                          children: [
                            // Select All Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_selectedNumbers.length} of ${widget.contacts!.length} selected',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _selectAll,
                                  child: Text(
                                    _selectedNumbers.length == widget.contacts!.length
                                        ? 'Deselect All'
                                        : 'Select All',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Contact List
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.contacts!.length,
                                itemBuilder: (context, index) {
                                  final contact = widget.contacts![index];
                                  final number = contact['contact']!;
                                  final name = contact['fullname']!;
                                  final isSelected = _selectedNumbers.contains(number);

                                  return InkWell(
                                    onTap: () => _toggleRecipient(number),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.blue.shade50 : null,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            activeColor: Colors.orange,
                                            onChanged: (value) => _toggleRecipient(number),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  number,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Message Section
                      const Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      buildField(
                        controller: _messageController,
                        label: 'Type your message here...',
                        icon: Icons.message,
                        newMaxLines: 6,
                      ),

                      const SizedBox(height: 8),

                      // Character Counter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_characterCount / $_maxCharacters characters',
                            style: TextStyle(
                              fontSize: 11,
                              color: _characterCount > _maxCharacters
                                  ? Colors.red
                                  : Colors.grey.shade600,
                            ),
                          ),
                          if (_characterCount > _maxCharacters)
                            Text(
                              'Message will be sent as ${(_characterCount / _maxCharacters).ceil()} SMS',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            DialogBottomNavigator(child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  text: 'Cancel',
                  icon: Icons.close,
                  color: Colors.red,
                  onPressed: () => Navigator.pop(context),
                ),
                CustomButton(
                  text: 'Send SMS',
                  icon: Icons.send,
                  color: Colors.green,
                  onPressed: () {
                    if (_validateAndSubmit()) {
                      // TODO: Implement SMS sending logic here
                      print('Sending SMS to: ${_getRecipientsSummary()}');
                      print('Message: ${_messageController.text}');

                      widget.onSubmit();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),)

          ],
        ),
      ),
    );
  }
}