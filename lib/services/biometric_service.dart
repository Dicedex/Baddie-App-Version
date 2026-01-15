import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometrics are available (mobile only)
  Future<bool> isBiometricAvailable() async {
    if (!_isMobile) return false;

    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate() async {
    if (!_isMobile) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock Baddie',
              );
    } catch (_) {
      return false;
    }
  }

  /// Helper to restrict biometrics to Android/iOS only
  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
