import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef IncomingCallCallback = void Function(String callerId, bool isVideo);

class CallService {
  // ------------------ Logger ------------------
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      colors: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // updated from deprecated printTime
    ),
  );

  // ------------------ Singleton ------------------
  CallService._privateConstructor();
  static final CallService instance = CallService._privateConstructor();

  // ------------------ Streams ------------------
  final StreamController<Map<String, dynamic>> _incomingCallController =
      StreamController.broadcast();

  void onIncomingCall(IncomingCallCallback callback) {
    _incomingCallController.stream.listen((data) {
      final callerId = data['callerId'] as String;
      final isVideo = data['isVideo'] as bool? ?? false;
      _logger.i('Incoming call from $callerId, video: $isVideo');
      callback(callerId, isVideo);
    });
  }

  void simulateIncomingCall({
    required String callerId,
    required bool isVideo,
  }) {
    _logger.i('Simulating incoming call from $callerId, video: $isVideo');
    _incomingCallController.add({
      'callerId': callerId,
      'isVideo': isVideo,
    });
  }

  // ------------------ Call Controls ------------------
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  bool _muted = false;
  bool _videoEnabled = true;

  Future<void> startCall({required bool video}) async {
    _logger.i('Starting ${video ? "video" : "voice"} call');

    // Get local media
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': video,
    });

    // Create PeerConnection
    _peerConnection = await createPeerConnection(
      {'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]},
    );

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Remote stream
    _remoteStream = await createLocalMediaStream('remote');
    _peerConnection?.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
      }
    };
  }

  void setMute(bool muted) {
    _muted = muted;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !muted;
    });
    _logger.i('Audio muted: $_muted');
  }

  void setVideoEnabled(bool enabled) {
    _videoEnabled = enabled;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = enabled;
    });
    _logger.i('Video enabled: $_videoEnabled');
  }

  Future<void> endCall(String callId) async {
    _logger.w('Ending call: $callId');

    // Close local and remote streams
    await _localStream?.dispose();
    await _remoteStream?.dispose();

    // Close peer connection
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;

    // Update Firestore call status
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .update({'status': 'ended'});

    _logger.i('Call $callId terminated successfully');
  }

  void dispose() {
    _logger.i('Disposing CallService');
    _incomingCallController.close();
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
  }
}
