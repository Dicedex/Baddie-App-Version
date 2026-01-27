import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile.dart';
import 'auth_service.dart';

class UserService {
  UserService._internal();
  static final UserService instance = UserService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _authService = AuthService();

  /// ValueNotifier holding the currently signed-in/created profile.
  final ValueNotifier<Profile?> currentUser = ValueNotifier<Profile?>(null);

  void setUser(Profile profile) {
    currentUser.value = profile;
  }

  void clear() {
    currentUser.value = null;
  }

  /// Load profile from Firestore
  Future<Profile?> loadProfileFromFirestore() async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) return null;

      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          // Ensure the profile has an id field (use UID if not present)
          if (!data.containsKey('id') || data['id'] == null || data['id'] == '') {
            data['id'] = currentUser.uid;
          }
          
          final profile = Profile.fromMap(data);
          setUser(profile);
          debugPrint('Profile loaded from Firestore: ${profile.name}');
          return profile;
        }
      }
      debugPrint('No Firestore document found for user: ${currentUser.uid}');
      return null;
    } catch (e) {
      debugPrint('Error loading profile from Firestore: $e');
      return null;
    }
  }

  /// Get profile from memory or Firestore
  Future<Profile?> getProfile() async {
    if (currentUser.value != null) {
      return currentUser.value;
    }
    return await loadProfileFromFirestore();
  }
}
