import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceService with WidgetsBindingObserver {
  final String userId; // <-- Add this to track which user
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PresenceService({required this.userId}) {
    // Register observer
    WidgetsBinding.instance.addObserver(this);
    _setOnline(); // Set online when initialized
  }

  // Called when app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnline();
    } else {
      _setOffline();
    }
  }

  void _setOnline() {
    _firestore.collection('users').doc(userId).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  void _setOffline() {
    _firestore.collection('users').doc(userId).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Call this when disposing the service
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
