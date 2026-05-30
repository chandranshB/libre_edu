class FFmpegSession {
  void cancel() {}
  Future<int?> getReturnCode() async => null;
}

class ReturnCode {
  static bool isSuccess(int? code) => false;
  static bool isCancel(int? code) => false;
}

class FFmpegKit {
  static Future<FFmpegSession> executeAsync(
    String command, {
    Function(FFmpegSession)? onComplete,
    Function(dynamic)? onLog,
    Function(dynamic)? onStatistics,
  }) async {
    return FFmpegSession();
  }
}
