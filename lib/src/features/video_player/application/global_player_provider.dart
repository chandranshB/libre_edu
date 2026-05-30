import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../courses/domain/video_lesson.dart';

class GlobalPlayerState {
  final Player? player;
  final List<VideoLesson> playlist;
  final int currentIndex;
  final bool isVisible;

  GlobalPlayerState({
    this.player,
    this.playlist = const [],
    this.currentIndex = -1,
    this.isVisible = false,
  });

  GlobalPlayerState copyWith({
    Player? player,
    List<VideoLesson>? playlist,
    int? currentIndex,
    bool? isVisible,
  }) {
    return GlobalPlayerState(
      player: player ?? this.player,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class GlobalPlayerNotifier extends StateNotifier<GlobalPlayerState> {
  GlobalPlayerNotifier() : super(GlobalPlayerState()) {
    _initPlayer();
  }

  void _initPlayer() {
    final player = Player(configuration: const PlayerConfiguration(bufferSize: 32 * 1024 * 1024));
    state = state.copyWith(player: player);
  }

  void playVideo(List<VideoLesson> playlist, int index) {
    if (index < 0 || index >= playlist.length) return;
    
    final video = playlist[index];
    state.player?.open(Media(video.m3u8Url));
    
    state = state.copyWith(
      playlist: playlist,
      currentIndex: index,
      isVisible: true,
    );
  }

  void closePlayer() {
    state.player?.stop();
    state = state.copyWith(isVisible: false);
  }

  VideoLesson? get currentVideo {
    if (state.currentIndex >= 0 && state.currentIndex < state.playlist.length) {
      return state.playlist[state.currentIndex];
    }
    return null;
  }

  @override
  void dispose() {
    state.player?.dispose();
    super.dispose();
  }
}

final globalPlayerProvider = StateNotifierProvider<GlobalPlayerNotifier, GlobalPlayerState>((ref) {
  return GlobalPlayerNotifier();
});
