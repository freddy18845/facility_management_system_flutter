import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fms_app/providers/app_Manager.dart';
import 'package:fms_app/screens/admins_screen/app_temple.dart';
import 'package:fms_app/screens/register_company.dart';
import 'package:fms_app/screens/tenant_screen/tenant_dashboard.dart';
import '../providers/auth_manager.dart';
import '../utils/api_service.dart';
import '../utils/app_theme.dart';
import 'btn.dart';
import 'loading.dart';
import 'textform.dart';
import '../screens/artisan_screen/artisan_dashboard_screen.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLogin() async {
    try {
      final creds = await AuthStorage.instance.loadCredentials();
      if (creds != null && mounted) {
        setState(() {
          _emailController.text = creds['email'] ?? '';
          _passwordController.text = creds['password'] ?? '';
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  Future<void> login() async {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {

      LoadingScreen.show(context, message: 'Loading...');

      try {
        final response = await ApiService().post(
          'login',
          {
            'email': _emailController.text.toLowerCase(),
            'password': _passwordController.text,
          },
          context,
          false,
        );

        if (mounted) LoadingScreen.hide(context);

        if (response?.statusCode == 200 || response?.statusCode == 201) {
          final responseData = jsonDecode(response!.body);

          debugPrint('📦 Response data: $responseData');

          // Save login data
          await AppManager().saveLoginData(
            data: responseData['data'],
          );

          // Save credentials
          await AuthStorage.instance.saveCredentials(
            email: _emailController.text,
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );

          // Get role using the getter method
          String? role = AppManager().getRole();

          debugPrint('👤 User role: $role');

          if (mounted) {
            if (role == "tenant") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TenantIssuesScreen()),
              );
            } else if (role == "artisan") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ArtisanScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminTemplate()),
              );
            }
          }
        } else {
          final errorData = jsonDecode(response!.body);
          if (mounted) {
            showCustomSnackBar(
              context,
              errorData['message'] ?? 'Login failed',
              color: Colors.red,
            );
          }
        }
      } catch (e, stackTrace) {
        if (mounted) LoadingScreen.hide(context);
        debugPrint('❌ Login error: $e');
        debugPrint('❌ Stack trace: $stackTrace');
        if (mounted) {
          showCustomSnackBar(
            context,
            'Login failed. Please try again.',
            color: Colors.red,
          );
        }
      }
    } else {
      showCustomSnackBar(
        context,
        'Please enter email and password',
        color: Colors.orange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Container(
      height: 420,
      width: isMobile ? size.width * 0.9 : 400,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1.5, color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onDoubleTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: Image.asset(
              'assets/images/tenant.png',
              height: isMobile ? 40 : 60,
              errorBuilder: (_, __, ___) => Icon(
                Icons.account_circle,
                size: isMobile ? 40 : 50,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Login Into Your Account',
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          buildField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          passwordField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock,
            isHidden: _isPasswordHidden,
            onToggle: () {
              setState(() {
                _isPasswordHidden = !_isPasswordHidden;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text("Remember Me", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: Navigate to forgot password screen
                  showCustomSnackBar(
                    context,
                    "Password reset feature coming soon",
                    color: Colors.blue,
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Login',
              color: Colors.blue,
              onPressed: login,
              isShowIcon: false,
              icon: Icons.login,
            ),
          ),
        ],
      ),
    );
  }
}
