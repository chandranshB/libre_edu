import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miniplayer/miniplayer.dart';
import '../application/global_player_provider.dart';
import '../../courses/presentation/course_detail_screen.dart'; // For CourseNodeWidget/LessonTile
import '../application/stream_quality_service.dart';

final miniplayerControllerProvider = Provider((ref) => MiniplayerController());

class GlobalPlayerWidget extends ConsumerStatefulWidget {
  const GlobalPlayerWidget({super.key});

  @override
  ConsumerState<GlobalPlayerWidget> createState() => _GlobalPlayerWidgetState();
}

class _GlobalPlayerWidgetState extends ConsumerState<GlobalPlayerWidget> {
  late final VideoController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final player = ref.read(globalPlayerProvider).player;
    if (player != null) {
      _controller = VideoController(player);
    }
  }

  void _scrollToCurrentVideo(int index) {
    if (_scrollController.hasClients && index >= 0) {
      // Approximate height of a ListTile to auto-scroll
      final offset = index * 72.0; 
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(globalPlayerProvider);
    final miniplayerController = ref.watch(miniplayerControllerProvider);

    if (!playerState.isVisible || playerState.player == null) {
      return const SizedBox.shrink();
    }

    ref.listen<GlobalPlayerState>(globalPlayerProvider, (previous, next) {
      if (previous?.currentIndex != next.currentIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentVideo(next.currentIndex);
        });
      }
    });

    final minHeight = 80.0;
    final maxHeight = MediaQuery.of(context).size.height;

    return Miniplayer(
      controller: miniplayerController,
      minHeight: minHeight,
      maxHeight: maxHeight,
      builder: (height, percentage) {
        final isMini = percentage < 0.2;

        if (isMini) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  height: minHeight,
                  child: Video(
                    controller: _controller,
                    controls: NoVideoControls,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      playerState.currentVideo?.title ?? 'Unknown Video',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(globalPlayerProvider.notifier).closePlayer();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          );
        }

        // Full Screen Player
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Video Player
                MaterialVideoControlsTheme(
                  normal: const MaterialVideoControlsThemeData(
                    buttonBarButtonSize: 24.0,
                    buttonBarButtonColor: Colors.white,
                  ),
                  fullscreen: const MaterialVideoControlsThemeData(
                    buttonBarButtonSize: 24.0,
                    buttonBarButtonColor: Colors.white,
                  ),
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                    child: Stack(
                      children: [
                        Video(controller: _controller),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                            onPressed: () => miniplayerController.animateToHeight(state: PanelState.MIN),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Current Video Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerState.currentVideo?.title ?? 'Playing Video',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                    ],
                  ),
                ),
                // Syllabus / Playlist
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: playerState.playlist.length,
                    itemBuilder: (context, index) {
                      final lesson = playerState.playlist[index];
                      final isPlaying = index == playerState.currentIndex;
                      
                      return Container(
                        color: isPlaying ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
                        child: LessonTile(lesson: lesson, isPlaylistMode: true, index: index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
