import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miniplayer/miniplayer.dart';
import '../application/global_player_provider.dart';
import '../../courses/presentation/course_detail_screen.dart'; // For CourseNodeWidget/LessonTile
import 'package:media_kit/media_kit.dart';
import '../../courses/application/stream_quality_service.dart';

final miniplayerControllerProvider = Provider((ref) => MiniplayerController());

class GlobalPlayerWidget extends ConsumerStatefulWidget {
  const GlobalPlayerWidget({super.key});

  @override
  ConsumerState<GlobalPlayerWidget> createState() => _GlobalPlayerWidgetState();
}

class _GlobalPlayerWidgetState extends ConsumerState<GlobalPlayerWidget> {
  late final VideoController _controller;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _videoKey = GlobalKey();

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

  void _showQualitySelectionDialog(String currentUrl) {
    final qualities = StreamQualityService.getAvailableQualities(currentUrl);
    
    if (qualities == null || qualities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quality options not available for this video.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Select Streaming Quality', style: Theme.of(context).textTheme.titleLarge),
              ),
              ...qualities.map((q) => ListTile(
                title: Text(q),
                leading: const Icon(Icons.hd),
                onTap: () async {
                  Navigator.pop(context);
                  final position = _controller.player.state.position;
                  final optimizedUrl = StreamQualityService.optimizeUrl(currentUrl, quality: q);
                  await _controller.player.open(Media(optimizedUrl));
                  await _controller.player.seek(position);
                },
              )).toList(),
            ],
          ),
        );
      }
    );
  }

  void _showPlaybackSpeedDialog() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Playback Speed', style: Theme.of(context).textTheme.titleLarge),
              ),
              ...speeds.map((speed) => ListTile(
                title: Text('${speed}x'),
                leading: const Icon(Icons.speed),
                onTap: () {
                  Navigator.pop(context);
                  _controller.player.setRate(speed);
                },
              )).toList(),
            ],
          ),
        );
      }
    );
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
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Video(
                      key: _videoKey,
                      controller: _controller,
                      controls: (state) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      playerState.currentVideo?.title ?? 'Playing Video',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    playerState.player?.state.playing == true ? Icons.pause : Icons.play_arrow
                  ),
                  onPressed: () => playerState.player?.playOrPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(globalPlayerProvider.notifier).closePlayer();
                  },
                ),
              ],
            ),
          );
        }

        // Full Screen Player
        final isDesktop = MediaQuery.of(context).size.width >= 800;

        final videoPlayerWidget = MaterialVideoControlsTheme(
          normal: MaterialVideoControlsThemeData(
            buttonBarButtonSize: 24.0,
            buttonBarButtonColor: Colors.white,
            topButtonBar: [
              const Spacer(),
              MaterialCustomButton(
                onPressed: _showPlaybackSpeedDialog,
                icon: const Icon(Icons.speed, color: Colors.white),
              ),
              MaterialCustomButton(
                onPressed: () {
                  if (playerState.currentVideo != null) {
                    _showQualitySelectionDialog(playerState.currentVideo!.m3u8Url);
                  }
                },
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          fullscreen: MaterialVideoControlsThemeData(
            buttonBarButtonSize: 24.0,
            buttonBarButtonColor: Colors.white,
            topButtonBar: [
              const Spacer(),
              MaterialCustomButton(
                onPressed: _showPlaybackSpeedDialog,
                icon: const Icon(Icons.speed, color: Colors.white),
              ),
              MaterialCustomButton(
                onPressed: () {
                  if (playerState.currentVideo != null) {
                    _showQualitySelectionDialog(playerState.currentVideo!.m3u8Url);
                  }
                },
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Video(
                    key: _videoKey,
                    controller: _controller,
                  ),
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
        );

        final videoInfoWidget = Padding(
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
        );

        final playlistWidget = ListView.builder(
          controller: _scrollController,
          itemCount: playerState.playlist.length,
          itemBuilder: (context, index) {
            final lesson = playerState.playlist[index];
            final isPlaying = index == playerState.currentIndex;
            
            return Container(
              color: isPlaying ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
              child: LessonTile(lesson: lesson, playlist: playerState.playlist, isPlaylistMode: true, index: index, courseTitle: playerState.courseTitle),
            );
          },
        );

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            miniplayerController.animateToHeight(state: PanelState.MIN);
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: GestureDetector(
              onTap: () {}, // Consume tap to prevent miniplayer from minimizing
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side: Video + Info
                          Expanded(
                            flex: 7,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  videoPlayerWidget,
                                  videoInfoWidget,
                                ],
                              ),
                            ),
                          ),
                          const VerticalDivider(width: 1, thickness: 1),
                          // Right side: Playlist
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(playerState.courseTitle.isNotEmpty ? playerState.courseTitle : 'Up Next', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                Expanded(child: playlistWidget),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          videoPlayerWidget,
                          videoInfoWidget,
                          Expanded(child: playlistWidget),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
