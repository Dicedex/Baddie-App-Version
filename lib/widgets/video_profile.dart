import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProfile extends StatefulWidget {
  final String videoUrl;
  const VideoProfile({super.key, required this.videoUrl});

  @override
  State<VideoProfile> createState() => _VideoProfileState();
}

class _VideoProfileState extends State<VideoProfile> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) => setState(() {}))
      ..setLooping(true)
      ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: VideoPlayer(_controller),
    );
  }
}
