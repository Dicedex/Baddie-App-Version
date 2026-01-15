import 'package:cloud_firestore/cloud_firestore.dart';

class BoostService {
  final _db = FirebaseFirestore.instance;

  /// Boost user for 30 minutes
  Future<void> activateBoost(String userId) async {
    await _db.collection('boosts').doc(userId).set({
      'active': true,
      'expiresAt': DateTime.now().add(const Duration(minutes: 30)),
    });
  }

  /// Check if boost is active
  Future<bool> isBoosted(String userId) async {
    final doc = await _db.collection('boosts').doc(userId).get();
    if (!doc.exists) return false;

    final expires = (doc['expiresAt'] as Timestamp).toDate();
    return DateTime.now().isBefore(expires);
  }
}
