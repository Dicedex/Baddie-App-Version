import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart'; // optional vibration package
import 'package:audioplayers/audioplayers.dart'; // optional ringtone

class CallScreen extends StatefulWidget {
  final String callId;
  final String callerName;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    this.isVideo = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // Replace these with your actual audio/video track types
  dynamic localAudioTrack;
  dynamic localVideoTrack;

  bool muted = false;
  bool cameraOff = false;
  bool callAccepted = false;
  late Timer _timeoutTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playRingtone();
    _startTimeout();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _timeoutTimer.cancel();
    super.dispose();
  }

  void _playRingtone() async {
    // Plays ringtone in a loop
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/ringtone.mp3')); // Add your ringtone in assets
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 1000, 1000, 1000], repeat: 0);
    }
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 40), () {
      if (!callAccepted) {
        _endCall();
      }
    });
  }

  void _acceptCall() {
    setState(() {
      callAccepted = true;
    });
    _audioPlayer.stop();
    _timeoutTimer.cancel();
    // Initialize your audio/video tracks here
  }

  void _declineCall() {
    _endCall();
  }

  void _toggleMute() {
    setState(() {
      muted = !muted;
      // localAudioTrack.enabled = !muted; // Uncomment when using actual track
    });
  }

  void _toggleCamera() {
    setState(() {
      cameraOff = !cameraOff;
      // localVideoTrack.enabled = !cameraOff; // Uncomment when using actual track
    });
  }

  void _endCall() {
    _audioPlayer.stop();
    _timeoutTimer.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (video or placeholder)
          Container(
            color: Colors.black,
            child: Center(
              child: callAccepted
                  ? Text(
                      widget.isVideo ? 'Video Call' : 'Audio Call',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call, size: 64, color: Colors.green),
                        const SizedBox(height: 20),
                        Text(
                          '${widget.callerName} is calling...',
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ],
                    ),
            ),
          ),
          // Buttons
          Positioned(
            bottom: 50,
            left: 50,
            right: 50,
            child: callAccepted
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(muted ? Icons.mic_off : Icons.mic),
                        color: Colors.white,
                        iconSize: 36,
                        onPressed: _toggleMute,
                      ),
                      if (widget.isVideo)
                        IconButton(
                          icon: Icon(cameraOff ? Icons.videocam_off : Icons.videocam),
                          color: Colors.white,
                          iconSize: 36,
                          onPressed: _toggleCamera,
                        ),
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        color: Colors.red,
                        iconSize: 36,
                        onPressed: _endCall,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        color: Colors.red,
                        iconSize: 50,
                        onPressed: _declineCall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.call),
                        color: Colors.green,
                        iconSize: 50,
                        onPressed: _acceptCall,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
