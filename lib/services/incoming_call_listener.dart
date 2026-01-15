import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A simple listener for incoming calls.
/// Call IncomingCallListener.start() from a screen to start listening.
class IncomingCallListener {
  static StreamSubscription<DocumentSnapshot>? _subscription;

  /// Start listening for incoming calls
  static void start({
    required BuildContext context,
    required String myUserId,
  }) {
    // Cancel previous subscription if exists
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(myUserId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      if (data['status'] == 'calling') {
        final String callerId = data['callerId'] ?? 'Unknown';

        // Guard against using context asynchronously
        if (!context.mounted) return;

        // Show simple alert dialog for incoming call
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Incoming Call'),
            content: Text('User $callerId is calling you'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Decline'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to your CallScreen here if needed
                },
                child: const Text('Accept'),
              ),
            ],
          ),
        );
      }
    });
  }

  /// Stop listening for incoming calls
  static void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
