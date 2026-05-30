import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:miniplayer/miniplayer.dart';
import '../../courses/domain/video_lesson.dart';
import '../presentation/global_player_widget.dart';
import 'video_progress_service.dart';

class GlobalPlayerState {
  final Player? player;
  final String courseTitle;
  final List<VideoLesson> playlist;
  final int currentIndex;
  final bool isVisible;

  GlobalPlayerState({
    this.player,
    this.courseTitle = '',
    this.playlist = const [],
    this.currentIndex = -1,
    this.isVisible = false,
  });

  GlobalPlayerState copyWith({
    Player? player,
    String? courseTitle,
    List<VideoLesson>? playlist,
    int? currentIndex,
    bool? isVisible,
  }) {
    return GlobalPlayerState(
      player: player ?? this.player,
      courseTitle: courseTitle ?? this.courseTitle,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  VideoLesson? get currentVideo {
    if (currentIndex >= 0 && currentIndex < playlist.length) {
      return playlist[currentIndex];
    }
    return null;
  }
}

class GlobalPlayerNotifier extends Notifier<GlobalPlayerState> {
  StreamSubscription<Duration>? _positionSub;

  @override
  GlobalPlayerState build() {
    final player = Player(configuration: const PlayerConfiguration(bufferSize: 32 * 1024 * 1024));
    
    // Save position periodically
    _positionSub = player.stream.position.listen((position) {
      if (position.inSeconds % 5 == 0 && position.inSeconds > 0) {
        final currentVid = state.currentVideo;
        if (currentVid != null) {
          ref.read(videoProgressServiceProvider.notifier).saveProgress(currentVid.id, position);
        }
      }
    });

    ref.onDispose(() {
      _positionSub?.cancel();
      player.dispose();
    });

    return GlobalPlayerState(player: player);
  }

  void playVideo(List<VideoLesson> playlist, int index, {String courseTitle = ''}) async {
    if (index < 0 || index >= playlist.length) return;
    
    final video = playlist[index];
    
    state = state.copyWith(
      courseTitle: courseTitle,
      playlist: playlist,
      currentIndex: index,
      isVisible: true,
    );

    // Ensure Miniplayer is maximized when a new video is explicitly played
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        ref.read(miniplayerControllerProvider).animateToHeight(state: PanelState.MAX);
      } catch (_) {}
    });

    try {
      await state.player?.open(Media(video.m3u8Url));
      
      final savedPosition = ref.read(videoProgressServiceProvider.notifier).getProgress(video.id);
      if (savedPosition != null && savedPosition.inSeconds > 0) {
        await state.player?.seek(savedPosition);
      }
    } catch (e) {
      // Ignore open/seek errors
    }
  }

  void closePlayer() {
    final currentVid = state.currentVideo;
    if (currentVid != null && state.player != null) {
      try {
        ref.read(videoProgressServiceProvider.notifier).saveProgress(currentVid.id, state.player!.state.position);
      } catch (_) {}
    }
    state.player?.stop();
    state = state.copyWith(isVisible: false);
  }
}

final globalPlayerProvider = NotifierProvider<GlobalPlayerNotifier, GlobalPlayerState>(GlobalPlayerNotifier.new);
