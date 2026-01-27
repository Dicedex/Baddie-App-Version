import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // These MUST be inside the class for the methods below to see them
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("Attempting login with: $email");
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("Login successful!");
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code}");
      rethrow;
    } catch (e) {
      debugPrint("General Error: $e");
      throw Exception('Login failed');
    }
  }

  /// SIGN UP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("AuthService: Starting signup for $email");
      
      // 1. Create the user in Auth (We save the result in 'credential')
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create the Firestore doc
      if (credential.user != null) {
        try {
          await _db.collection('users').doc(credential.user!.uid).set({
            'uid': credential.user!.uid,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'profileCompleted': false,
            'displayName': '',
            'photoUrl': '',
            'bio': '',
          });
          debugPrint("✅ Firestore record created.");
        } catch (dbError) {
          debugPrint("⚠️ Firestore write failed (check your rules): $dbError");
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("AUTH ERROR: ${e.code}");
      rethrow;
    } catch (e) {
      // Handles the weird Flutter Web TypeErrors
      debugPrint("General Signup Error: $e");
      throw Exception("An unexpected error occurred during signup.");
    }
  }

  /// UPDATE PROFILE (This was likely outside the brace)
  Future<void> updateProfile({
    required String name,
    required String bio,
    String? photoUrl,
  }) async {
    try {
      String uid = _auth.currentUser!.uid; // Now it can see _auth
      await _db.collection('users').doc(uid).update({ // Now it can see _db
        'displayName': name,
        'bio': bio,
        'photoUrl': photoUrl ?? '',
        'profileCompleted': true,
      });
    } catch (e) {
      debugPrint("Update Profile Error: $e");
      rethrow;
    }
  }

  /// FORGOT PASSWORD
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint("Password Reset Error: ${e.code}");
      rethrow;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

} // <--- MAKE SURE THIS IS THE VERY LAST LINE OF YOUR FILE