import 'dart:async'; // required for StreamSubscription
import 'package:flutter/foundation.dart'; // required for VoidCallback

class CallReconnectService {
  StreamSubscription? _subscription;
  VoidCallback? onReconnect;

  CallReconnectService({this.onReconnect});

  void startListening(Stream events) {
    _subscription = events.listen((event) {
      // Handle reconnect event
      if (onReconnect != null) onReconnect!();
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
