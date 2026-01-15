import 'dart:math';

class MatchEngine {
  static double calculateScore({
    required Map<String, dynamic> me,
    required Map<String, dynamic> other,
  }) {
    double score = 0;

    // 1️⃣ Intent compatibility (30)
    if (me['intent'] == other['intent']) {
      score += 30;
    }

    // 2️⃣ Age distance (20)
    final ageDiff = (me['age'] - other['age']).abs();
    score += max(0, 20 - ageDiff * 2);

    // 3️⃣ Interests overlap (20)
    final myInterests = Set.from(me['interests'] ?? []);
    final theirInterests = Set.from(other['interests'] ?? []);
    final overlap = myInterests.intersection(theirInterests).length;
    score += min(20, overlap * 5);

    // 4️⃣ Location proximity (20)
    final dist = _distanceKm(
      me['location']['lat'],
      me['location']['lng'],
      other['location']['lat'],
      other['location']['lng'],
    );
    score += max(0, 20 - dist);

    // 5️⃣ Activity (10)
    final lastActive = DateTime.parse(other['lastActive']);
    final hoursAgo = DateTime.now().difference(lastActive).inHours;
    score += max(0, 10 - hoursAgo / 6);

    return score.clamp(0, 100);
  }

  static double _distanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _deg2rad(double deg) => deg * pi / 180;
}
