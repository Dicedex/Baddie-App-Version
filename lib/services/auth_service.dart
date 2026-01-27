import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print("Attempting login with: $email");
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Login successful!");
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      throw Exception(e.message ?? 'Login failed');
    }
    catch (e) {
    print("General Error: $e"); // 👈 ADD THIS
    throw Exception('Check your credentials and try again');
    }
  }

  /// NEW: FORGOT PASSWORD
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  /// SIGN UP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return; // ✅ explicitly end
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Signup failed');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    return; // ✅ good practice
  }
}
