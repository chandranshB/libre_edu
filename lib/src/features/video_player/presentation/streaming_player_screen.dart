import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../application/video_progress_service.dart';

class StreamingPlayerScreen extends ConsumerStatefulWidget {
  final String videoUrl;
  final String title;
  final String? videoId;

  const StreamingPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    this.videoId,
  });

  @override
  ConsumerState<StreamingPlayerScreen> createState() => _StreamingPlayerScreenState();
}

class _StreamingPlayerScreenState extends ConsumerState<StreamingPlayerScreen> {
  // Create a [Player] to control playback with optimized buffer.
  late final player = Player(configuration: const PlayerConfiguration(bufferSize: 32 * 1024 * 1024));
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  StreamSubscription<Duration>? _positionSub;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.open(Media(widget.videoUrl));
    
    if (widget.videoId != null) {
      // Seek to saved position once playing
      player.stream.playing.listen((playing) async {
        if (playing && !_isInitialized) {
          _isInitialized = true;
          final savedPosition = ref.read(videoProgressServiceProvider.notifier).getProgress(widget.videoId!);
          if (savedPosition != null && savedPosition.inSeconds > 0) {
            await player.seek(savedPosition);
          }
        }
      });

      // Save position periodically
      _positionSub = player.stream.position.listen((position) {
        if (position.inSeconds % 5 == 0 && position.inSeconds > 0) {
          ref.read(videoProgressServiceProvider.notifier).saveProgress(widget.videoId!, position);
        }
      });
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    
    final currentPosition = player.state.position;
    // Stop playback immediately to prevent background audio and stacking
    player.stop();
    player.dispose();
    
    if (widget.videoId != null) {
      try {
        ref.read(videoProgressServiceProvider.notifier).saveProgress(widget.videoId!, currentPosition);
      } catch (_) {
        // Safe to ignore if Riverpod throws during dispose
      }
    }
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
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent || event is KeyRepeatEvent) {
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.space) {
                player.playOrPause();
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.arrowLeft) {
                final pos = player.state.position;
                player.seek(pos - const Duration(seconds: 10));
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.arrowRight) {
                final pos = player.state.position;
                player.seek(pos + const Duration(seconds: 10));
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9.0 / 16.0,
            child: Video(controller: controller),
          ),
        ),
      ),
    );
  }
}
