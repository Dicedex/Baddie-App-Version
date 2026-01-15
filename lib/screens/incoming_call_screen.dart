import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ringtone_service.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callerName;
  final bool video;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    required this.video,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    RingtoneService.play();

    // Auto-decline call after 40 seconds
    _timeoutTimer = Timer(const Duration(seconds: 40), () async {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .update({'status': 'missed'});

      if (!mounted) return;
      RingtoneService.stop();
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    RingtoneService.stop();
    super.dispose();
  }

  void _accept() async {
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .update({'status': 'accepted'});

    RingtoneService.stop();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          video: widget.video,
          callId: widget.callId, // Required argument passed
        ),
      ),
    );
  }

  void _decline() async {
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .update({'status': 'ended'});

    RingtoneService.stop();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 96, color: Colors.white70),
            const SizedBox(height: 24),
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.video ? 'Incoming video call' : 'Incoming voice call',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _callButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: _decline,
                ),
                _callButton(
                  icon: Icons.call,
                  color: Colors.green,
                  onTap: _accept,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _callButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CircleAvatar(
      radius: 36,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: onTap,
      ),
    );
  }
}
