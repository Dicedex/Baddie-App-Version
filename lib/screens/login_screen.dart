import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ─────────────────────────── Controllers & Services ───────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final BiometricService _biometricService = BiometricService();

  // ─────────────────────────── UI State ───────────────────────────
  bool _loading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // ─────────────────────────── Lifecycle ───────────────────────────
  @override
  void initState() {
    super.initState();
    _attemptBiometricLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────── Error Feedback (Toasts) ───────────────────────────
 // ─────────────────────────── Professional Error Toasts ───────────────────────────

  void _showErrorToast(dynamic e) {
    String message = 'Check your credentials and try again';
    
    if (e is FirebaseAuthException) {
      // This helps you see the exact code in your debug console
      debugPrint("Firebase Error Code: ${e.code}");

      switch (e.code) {
        case 'user-not-found':
          message = 'This email is not registered. Please sign up first.';
          break;
        case 'invalid-credential':
          // Modern Firebase returns this for both "user not found" and "wrong password"
          message = 'Invalid email or password.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        default:
          message = e.message ?? 'Authentication failed';
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────── Forgot Password Pop-up ───────────────────────────

  void _showForgotPasswordDialog() {
    // Pre-fill with whatever they already typed in the email field
    final TextEditingController resetController = TextEditingController(text: _emailController.text);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email and we will send you a reset link.'),
            const SizedBox(height: 15),
            TextField(
              controller: resetController,
              decoration: const InputDecoration(
                labelText: 'Email Address', 
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resetController.text.isEmpty) return;
              try {
                await AuthService().sendPasswordReset(resetController.text.trim());
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset link sent to your email!'), 
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                _showErrorToast(e);
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Biometric Login ───────────────────────────
  Future<void> _attemptBiometricLogin() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable) return;

    final success = await _biometricService.authenticate();
    if (!success || !mounted) return;

    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // ─────────────────────────── Validators ───────────────────────────
  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required';
    }

    final input = value.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    bool looksLikePhone(String s) {
      final digits = s.replaceAll(RegExp(r'[^\d+]'), '');
      return RegExp(r'^\+?\d{7,15}$').hasMatch(digits);
    }

    if (!emailRegex.hasMatch(input) && !looksLikePhone(input)) {
      return 'Enter a valid email or phone number';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(value);

    if (value.length < 8 || !hasLetter || !hasSpecial) {
      return '8+ chars with a letter & special character';
    }

    return null;
  }

  // ─────────────────────────── Submit Login ───────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await AuthService().loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorToast(e); // Professional toast notification
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────── UI ───────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Baddie'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email or phone',
                    ),
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: _passwordValidator,
                  ),

                  // NEW: Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign in'),
                    ),
                  ),

                  // NEW: Sign Up Navigation Link
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}