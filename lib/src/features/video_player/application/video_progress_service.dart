import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final videoProgressServiceProvider = AsyncNotifierProvider<VideoProgressService, Map<String, Duration>>(() {
  return VideoProgressService();
});

class VideoProgressService extends AsyncNotifier<Map<String, Duration>> {
  static const _prefix = 'video_progress_';

  @override
  FutureOr<Map<String, Duration>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Duration> progressMap = {};
    
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        final videoId = key.substring(_prefix.length);
        final milliseconds = prefs.getInt(key);
        if (milliseconds != null) {
          progressMap[videoId] = Duration(milliseconds: milliseconds);
        }
      }
    }
    return progressMap;
  }

  Future<void> saveProgress(String videoId, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$videoId', position.inMilliseconds);
    
    final currentMap = state.value ?? {};
    state = AsyncValue.data({...currentMap, videoId: position});
  }

  Duration? getProgress(String videoId) {
    return state.value?[videoId];
  }
}
