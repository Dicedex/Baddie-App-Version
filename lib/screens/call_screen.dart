import 'package:flutter/material.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final bool video;
  final String callId; // <-- Add callId

  const CallScreen({
    super.key,
    required this.video,
    required this.callId, // <-- required callId
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService.instance;

  bool _isMuted = false;
  bool _isVideoEnabled = true;

  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.video;
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _callService.setMute(_isMuted);
  }

  void _toggleVideo() {
    setState(() => _isVideoEnabled = !_isVideoEnabled);
    _callService.setVideoEnabled(_isVideoEnabled);
  }

  void _endCall() {
    _callService.endCall(widget.callId); // <-- pass callId
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isVideoEnabled
                ? Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.videocam, size: 100, color: Colors.white30),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.mic_off, size: 100, color: Colors.white30),
                    ),
                  ),
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _toggleMute,
                  icon: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: _toggleVideo,
                  icon: Icon(
                    _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: _endCall,
                  icon: const Icon(Icons.call_end, color: Colors.red, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
