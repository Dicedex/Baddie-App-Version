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
            'id': credential.user!.uid,
            'uid': credential.user!.uid,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'profileCompleted': false,
            'displayName': '',
            'name': '',
            'age': 18,
            'photoUrl': '',
            'imageUrl': '',
            'bio': '',
            'interests': [],
            'personality': 'Casual',
            'preferences': {
              'maxDistance': 50,
              'ageRangeStart': 18,
              'ageRangeEnd': 40,
              'verifiedOnly': false,
            },
            'status': 'online',
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

  /// GET CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// LOAD PROFILE FROM FIRESTORE
  Future<Map<String, dynamic>?> loadProfileFromFirestore() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final docSnapshot = await _db
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists) {
        debugPrint("Profile loaded from Firestore: ${docSnapshot.data()}");
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      debugPrint("Error loading profile: $e");
      return null;
    }
  }

} // <--- MAKE SURE THIS IS THE VERY LAST LINE OF YOUR FILE