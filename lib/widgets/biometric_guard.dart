import 'package:flutter/material.dart';
import '../services/biometric_service.dart';

class BiometricGuard extends StatefulWidget {
  final Widget child;

  const BiometricGuard({super.key, required this.child});

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard> {
  final BiometricService _biometricService = BiometricService();
  bool _authenticated = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _runBiometricCheck();
  }

  Future<void> _runBiometricCheck() async {
    final available = await _biometricService.isBiometricAvailable();

    if (!available) {
      setState(() {
        _authenticated = true;
        _checking = false;
      });
      return;
    }

    final success = await _biometricService.authenticate();

    if (!mounted) return;

    setState(() {
      _authenticated = success;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_authenticated) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Authentication required',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return widget.child;
  }
}
