import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceMessageBubble extends StatefulWidget {
  final String url;
  final bool mine;

  const VoiceMessageBubble({super.key, required this.url, required this.mine});

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final _player = AudioPlayer();
  bool playing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: widget.mine ? Colors.pink : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
        onPressed: () async {
          if (playing) {
            await _player.pause();
          } else {
            await _player.play(UrlSource(widget.url));
          }
          setState(() => playing = !playing);
        },
      ),
    );
  }
}
