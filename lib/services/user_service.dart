import 'package:flutter/foundation.dart';
import '../models/profile.dart';

class UserService {
  UserService._internal();
  static final UserService instance = UserService._internal();

  /// ValueNotifier holding the currently signed-in/created profile.
  final ValueNotifier<Profile?> currentUser = ValueNotifier<Profile?>(null);

  void setUser(Profile profile) {
    currentUser.value = profile;
  }

  void clear() {
    currentUser.value = null;
  }
}
