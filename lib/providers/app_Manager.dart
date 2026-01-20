import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppManager {
  static final AppManager _instance = AppManager._internal();

  factory AppManager() => _instance;

  AppManager._internal();

  // Keys for SharedPreferences
  static const String _keyUserStatus = 'user_status';
  static const String _keyFirstName = 'first_name';
  static const String _keyLoginToken = 'login_token';
  static const String _keyCompanyLogo = 'company_logo';
  static const String _keyLoginResponse = 'login_response';

  // In-memory variables
  String loginToken = '';
  Map<String, dynamic> loginResponse = {};

  Future<void> saveLoginData({
    required Map<String, dynamic> data,
  }) async {
    try {
      loginResponse = data;

      // Extract token
      loginToken = loginResponse["token"]?.toString() ?? '';

      // Get user data (which could be tenant, artisan, or staff/admin)
      Map<String, dynamic>? userData = loginResponse["user"];

      // Extract role
      String role = loginResponse["role"]?.toString() ?? '';

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Save the entire response as JSON for easy retrieval
      await prefs.setString(_keyLoginResponse, jsonEncode(data));

      // Save individual fields
      await prefs.setString(_keyLoginToken, loginToken);
      await prefs.setString(_keyUserStatus, role);

      // Save first name - handle both direct and nested structures
      String firstName = '';
      if (userData != null) {
        firstName = userData["first_name"]?.toString() ?? '';
      }
      await prefs.setString(_keyFirstName, firstName);

      // Save company logo URL if exists
      String companyLogo = '';
      if (userData != null && userData["company"] != null) {
        companyLogo = userData["company"]["logo_url"]?.toString() ?? '';
      }
      await prefs.setString(_keyCompanyLogo, companyLogo);

      print('✅ Login data saved successfully');
      print('👤 Role: $role');
      print('🔑 Token: ${loginToken.substring(0, 20)}...');

    } catch (e) {
      print('❌ Error saving login data: $e');
    }
  }


  /// Use this after a successful payment verification
  Future<void> updateCompanyData(Map<String, dynamic> newCompanyData) async {
    try {
      if (loginResponse.containsKey("user")) {
        loginResponse["user"]["company"] = newCompanyData;

        // Save to disk so it persists on restart
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('login_response', jsonEncode(loginResponse));

        print("✅ AppManager updated with: ${newCompanyData['sms_count']} SMS");
      } else {
        print("❌ Update failed: 'user' key not found in loginResponse");
      }
    } catch (e) {
      print('❌ Error updating company data: $e');
    }
  }
  // Load saved login data
  Future<void> loadLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load the entire response
      String? savedResponse = prefs.getString(_keyLoginResponse);
      if (savedResponse != null) {
        loginResponse = jsonDecode(savedResponse);
        loginToken = prefs.getString(_keyLoginToken) ?? '';
        print('✅ Login data loaded from storage');
      }
    } catch (e) {
      print('❌ Error loading login data: $e');
    }
  }

  // Clear login data (for logout)
  Future<void> clearLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLoginResponse);
      await prefs.remove(_keyLoginToken);
      await prefs.remove(_keyFirstName);
      await prefs.remove(_keyCompanyLogo);
      await prefs.remove(_keyUserStatus);

      loginResponse = {};
      loginToken = '';

      print('✅ Login data cleared');
    } catch (e) {
      print('❌ Error clearing login data: $e');
    }
  }

  // Getters
  String getLoginToken() => loginToken;

  String? getRole() => loginResponse["role"]?.toString();

  String? getFirstName() {
    final userData = loginResponse["user"];
    if (userData != null) {
      return userData["first_name"]?.toString();
    }
    return null;
  }

  int? getTenantId() {
    final role = getRole();
    if (role == 'tenant') {
      final userData = loginResponse["user"];
      return userData?["profile"]["id"] as int?;
    }
    return null;
  }

  int? getArtisanId() {
    final role = getRole();
    if (role == 'artisan') {
      final userData = loginResponse["user"];
      return userData?["profile"]["id"] as int?;
    }
    return null;
  }

  int? getUserId() {
    final userData = loginResponse["user"];
    return userData?["user_id"] as int? ?? userData?["id"] as int?;
  }

  int? getCompanyId() {
    final userData = loginResponse["user"];
    if (userData != null ) {
      return userData["company_id"] as int?;
    }
    return null;
  }

  String? getCompanyLogo() {
    final userData = loginResponse["user"];
    if (userData != null && userData["company"] != null) {
      return userData["company"]["logo_url"]?.toString();
    }
    return null;
  }

  int? getRoomId() {
    final role = getRole();
    if (role == 'tenant') {
      final userData = loginResponse["user"];
      if (userData != null && userData["room"] != null) {
        return userData["room"]["id"] as int?;
      }
    }
    return null;
  }

  // Check if user is logged in
  bool isLoggedIn() => loginToken.isNotEmpty;
}