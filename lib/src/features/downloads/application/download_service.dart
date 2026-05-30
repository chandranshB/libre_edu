import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ffmpeg_stub.dart' if (dart.library.io) 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../courses/application/m3u8_parser_service.dart';

enum DownloadStatus { downloading, completed, failed, cancelled, paused }

class DownloadState {
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final FFmpegSession? session;

  const DownloadState({
    required this.status,
    required this.progress,
    this.session,
  });

  DownloadState copyWith({DownloadStatus? status, double? progress, FFmpegSession? session}) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      session: session ?? this.session,
    );
  }
}

// Pass ref to access m3u8ParserServiceProvider
final downloadServiceProvider = NotifierProvider<DownloadService, Map<String, DownloadState>>(() {
  return DownloadService();
});

class DownloadService extends Notifier<Map<String, DownloadState>> {
  @override
  Map<String, DownloadState> build() {
    return {};
  }

  Future<void> checkExistingDownloads(String videoId) async {
    if (kIsWeb) return;
    final path = await getOfflineVideoPath(videoId);
    if (path != null) {
      state = {
        ...state,
        videoId: DownloadState(status: DownloadStatus.completed, progress: 1.0)
      };
    }
  }

  Future<void> downloadAndConvertM3u8(String m3u8Url, String videoId) async {
    if (kIsWeb) return;
    final Directory directory = await getApplicationDocumentsDirectory();
    final String outputPath = '${directory.path}/$videoId.mp4';
    
    if (File(outputPath).existsSync()) {
      state = {
        ...state,
        videoId: DownloadState(status: DownloadStatus.completed, progress: 1.0)
      };
      return;
    }

    // Immediately update UI to downloading so it doesn't freeze
    state = {
      ...state,
      videoId: DownloadState(status: DownloadStatus.downloading, progress: 0.0)
    };

    // Fetch duration in background
    final parser = ref.read(m3u8ParserServiceProvider);
    final totalDurationSeconds = await parser.getDurationSeconds(m3u8Url);

    final command = '-y -user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -i "$m3u8Url" -c copy "$outputPath"';

    final session = await FFmpegKit.executeAsync(
      command,
      onComplete: (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          state = {
            ...state,
            videoId: state[videoId]!.copyWith(status: DownloadStatus.completed, progress: 1.0)
          };
        } else if (ReturnCode.isCancel(returnCode)) {
          state = {
            ...state,
            videoId: state[videoId]!.copyWith(status: DownloadStatus.cancelled)
          };
          if (File(outputPath).existsSync()) File(outputPath).deleteSync();
        } else {
          state = {
            ...state,
            videoId: state[videoId]!.copyWith(status: DownloadStatus.failed)
          };
          if (File(outputPath).existsSync()) File(outputPath).deleteSync();
        }
      },
      onLog: (log) {},
      onStatistics: (statistics) {
        if (totalDurationSeconds > 0) {
          final timeInMilliseconds = statistics.time;
          if (timeInMilliseconds > 0) {
            double progress = (timeInMilliseconds / 1000) / totalDurationSeconds;
            if (progress > 1.0) progress = 1.0;
            if (progress < 0.0) progress = 0.0;
            
            if (state[videoId]?.status == DownloadStatus.downloading) {
              state = {
                ...state,
                videoId: state[videoId]!.copyWith(progress: progress)
              };
            }
          }
        }
      },
    );

    // Save session so we can cancel it
    if (state[videoId]?.status == DownloadStatus.downloading) {
      state = {
        ...state,
        videoId: state[videoId]!.copyWith(session: session)
      };
    }
  }

  Future<void> pauseDownload(String videoId) async {
    // FFmpeg doesn't cleanly pause/resume M3U8 HLS streams without complex state tracking.
    // We will map pause to cancel for now to prevent getting stuck.
    await cancelDownload(videoId);
  }

  Future<void> cancelDownload(String videoId) async {
    final s = state[videoId];
    if (s != null && s.session != null && s.status == DownloadStatus.downloading) {
      s.session!.cancel();
      state = {
        ...state,
        videoId: s.copyWith(status: DownloadStatus.cancelled)
      };
    }
  }

  Future<String?> getOfflineVideoPath(String videoId) async {
    if (kIsWeb) return null;
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/$videoId.mp4';
    final file = File(path);
    if (await file.exists()) {
      return path;
    }
    return null;
  }
}
