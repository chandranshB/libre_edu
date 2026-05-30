import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class StreamingPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const StreamingPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<StreamingPlayerScreen> createState() => _StreamingPlayerScreenState();
}

class _StreamingPlayerScreenState extends State<StreamingPlayerScreen> {
  // Create a [Player] to control playback with optimized buffer.
  late final player = Player(configuration: const PlayerConfiguration(bufferSize: 32 * 1024 * 1024));
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.open(Media(widget.videoUrl));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 9.0 / 16.0,
          child: Video(controller: controller),
        ),
      ),
    );
  }
}
