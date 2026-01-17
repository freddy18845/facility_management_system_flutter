import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  // Singleton boilerplate
  AuthStorage._privateConstructor();
  static final AuthStorage instance = AuthStorage._privateConstructor();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save login credentials if rememberMe is true
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await init();
print('remember_me${rememberMe.toString()}');
    if (rememberMe) {
      await _prefs?.setBool('remember_me', true);
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);
    } else {
      await clearCredentials();
    }
  }

  // Load saved credentials
  Future<Map<String, String>?> loadCredentials() async {
    await init();

    final rememberMe = _prefs?.getBool('remember_me') ?? false;
    if (!rememberMe) return null;

    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }

    return null;
  }

  // Clear saved credentials (logout)
  Future<void> clearCredentials() async {
    await init();
    await _prefs?.setBool('remember_me', false);
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
  }

  // Check if user chose remember me
  Future<bool> isRemembered() async {
    await init();
    return _prefs?.getBool('remember_me') ?? false;
  }
}
