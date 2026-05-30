import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:path_provider/path_provider.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

class DownloadService {
  Future<void> downloadAndConvertM3u8(String m3u8Url, String videoId) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String outputPath = '${directory.path}/$videoId.mp4';

    print('Starting download and conversion for $videoId...');
    print('Output path: $outputPath');

    // Run FFmpeg command: download m3u8 and copy to mp4 losslessly
    final command = '-y -i "$m3u8Url" -c copy "$outputPath"';

    await FFmpegKit.executeAsync(command, onComplete: (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('Successfully downloaded and converted video $videoId');
        // TODO: Save to local database that this video is downloaded
      } else if (ReturnCode.isCancel(returnCode)) {
        print('Download cancelled for $videoId');
      } else {
        print('Download failed for $videoId. Return code $returnCode');
        final logs = await session.getLogsAsString();
        print(logs);
      }
    });
  }

  Future<String?> getOfflineVideoPath(String videoId) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/$videoId.mp4';
    final file = File(path);
    if (await file.exists()) {
      return path;
    }
    return null;
  }
}
