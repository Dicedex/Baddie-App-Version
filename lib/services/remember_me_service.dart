import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

class RememberMeService {
  static const String _emailKey = 'baddie_remember_email';
  static const String _passwordKey = 'baddie_remember_password';
  static const String _rememberMeKey = 'baddie_remember_me';

  /// Save user credentials if remember me is enabled
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (rememberMe) {
        await prefs.setString(_emailKey, email);
        await prefs.setString(_passwordKey, password);
        await prefs.setBool(_rememberMeKey, true);
      } else {
        // Clear saved credentials if remember me is unchecked
        await clearCredentials();
      }
    } catch (e) {
      debugPrint("Error saving credentials: $e");
    }
  }

  /// Retrieve saved credentials
  Future<Map<String, dynamic>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
      
      if (!rememberMe) {
        return {
          'email': '',
          'password': '',
          'rememberMe': false,
        };
      }

      final email = prefs.getString(_emailKey) ?? '';
      final password = prefs.getString(_passwordKey) ?? '';

      return {
        'email': email,
        'password': password,
        'rememberMe': rememberMe,
      };
    } catch (e) {
      debugPrint("Error retrieving credentials: $e");
      return {
        'email': '',
        'password': '',
        'rememberMe': false,
      };
    }
  }

  /// Clear all saved credentials
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
      await prefs.remove(_rememberMeKey);
    } catch (e) {
      debugPrint("Error clearing credentials: $e");
    }
  }

  /// Check if user has saved credentials
  Future<bool> hasSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      return false;
    }
  }
}
