import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A service that handles:
/// 1. User presence (online/offline)
/// 2. Incoming call listener
class UserPresenceService with WidgetsBindingObserver {
  final String userId; // Current logged-in user ID
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream to listen for incoming calls
  Stream<DocumentSnapshot<Map<String, dynamic>>> get incomingCallStream {
    return _firestore.collection('calls').doc(userId).snapshots();
  }

  UserPresenceService({required this.userId}) {
    // Register for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    _setOnline(); // Set online when service starts
  }

  /// Called when app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnline();
    } else {
      _setOffline();
    }
  }

  /// Set the user as online in Firestore
  void _setOnline() {
    _firestore.collection('users').doc(userId).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Set the user as offline in Firestore
  void _setOffline() {
    _firestore.collection('users').doc(userId).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Dispose the service when not needed
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
