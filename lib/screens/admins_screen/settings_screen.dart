import 'package:flutter/material.dart';
import '../../Models/company_data.dart';
import '../../main.dart';
import '../../providers/app_Manager.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/settings_card.dart';
import '../dailogs/company_dailog.dart';
import '../dailogs/payment_upgrade_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  final Role = capitalizeFirst(AppManager().getRole()!);

  @override
  Widget build(BuildContext context) {
    final companyJson = AppManager().loginResponse["user"]["company"];
    final Company? companyData = companyJson != null
        ? Company.fromJson(Map<String, dynamic>.from(companyJson))
        : null;
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(onTap: (){
                  CompanySettingsDialog.show(context,companyJson);
                },
                child: buildSection(
                  context: context,
                  title: 'Company info',
                  icon: Icons.store_mall_directory_outlined,
                  color: Colors.blue,
                  showEdit:Role=="Admin"?true:false,
                  children: [
                    buildListTile(
                      icon: Icons.apartment_outlined,
                      title: 'Name',
                      subtitle: companyData!.name??"N/A",
                      trailing: const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    buildListTile(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      subtitle: companyData.address??'N/A',
                      trailing: const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    buildListTile(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: companyData.email ??"N/A",
                      trailing: const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    buildListTile(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      subtitle: companyData.phone??"N/A",
                      trailing: const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    buildListTile(
                      icon: Icons.insert_drive_file_outlined,
                      title: 'Subscription Expire Date',
                      subtitle:formatDate(companyData.subscriptionEndDate!),
                      onTap: () {
                        PaymentUpgradeDialog.show(context );
                      },
                    ),buildListTile(
                      icon: Icons.chat_outlined,
                      title: 'SMS',
                      subtitle:companyData.smsCount.toString(),
                      onTap: () {
                        PaymentUpgradeDialog.show(context );
                      },
                    ),
                  ],
                ),),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: buildSection(
                        title: 'Appearance',
                        icon: Icons.palette,
                        color: Colors.purple,
                        children: [
                          _buildSwitchTile(
                            icon: Icons.dark_mode,
                            title: 'Dark Mode',
                            subtitle: 'Switch between light and dark theme',
                            value: _darkMode,
                            onChanged: (value) {
                              setState(() {
                                _darkMode = value;
                              });

                              themeNotifier.value = _darkMode
                                  ? ThemeMode.dark
                                  : ThemeMode.light;

                              showCustomSnackBar(
                                context,
                                _darkMode
                                    ? 'Dark mode enabled'
                                    : 'Light mode enabled',
                                color: Colors.purple,
                              );
                            },
                          ),

                          buildListTile(
                            icon: Icons.language,
                            title: 'Language',
                            subtitle: _selectedLanguage,

                            onTap: () {
                              _showLanguageDialog();
                            },
                              ),
                        ],
                        context: context,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: // Security & Privacy Section
                      buildSection(
                        context: context,
                        title: 'Security & Privacy',
                        icon: Icons.security,
                        color: Colors.red,
                        children: [
                          buildListTile(
                            icon: Icons.privacy_tip,
                            title: 'Privacy Policy',
                            subtitle: 'View our privacy policy',
                            onTap: () {
                              // TODO: Show privacy policy
                            },
                          ),
                          buildListTile(
                            icon: Icons.description,
                            title: 'Terms of Service',
                            subtitle: 'View terms and conditions',
                            onTap: () {
                              // TODO: Show terms
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Appearance Section
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: Colors.grey.shade700),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue.shade700,
      ),
      dense: true,
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'This feature will allow you to change your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showCustomSnackBar(
                context,
                'Password change - Coming Soon',
                color: Colors.blue,
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'French', 'Spanish', 'German'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                showCustomSnackBar(
                  context,
                  'Language changed to $value',
                  color: Colors.purple,
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Tell us what you think...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showCustomSnackBar(
                context,
                'Thank you for your feedback!',
                color: Colors.green,
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
