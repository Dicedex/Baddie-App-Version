import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:local_auth/local_auth.dart';
import 'dart:io' show Platform;

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometrics are available (mobile only)
  Future<bool> isBiometricAvailable() async {
    // Always return false on web
    if (kIsWeb) return false;

    try {
      // Check if running on mobile platforms
      if (!_isMobile) return false;

      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint("Biometric availability check error: $e");
      return false;
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate() async {
    if (!_isMobile) return false;
    if (kIsWeb) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to Unlock Baddie',
      );
    } catch (e) {
      debugPrint("Biometric authentication error: $e");
      return false;
    }
  }

  /// Helper to restrict biometrics to Android/iOS only
  bool get _isMobile {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }
}