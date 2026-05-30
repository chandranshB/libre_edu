class StreamQualityService {
  /// Returns available qualities if it is a supported master playlist
  static List<String>? getAvailableQualities(String url) {
    if (url.contains('studyiq.com') && url.endsWith('masterpl.m3u8')) {
      return ['720p', '480p', '360p', '160p'];
    }
    return null;
  }

  /// Rewrites the master playlist URL to directly target the specified quality
  static String optimizeUrl(String url, {String quality = '480p'}) {
    if (url.contains('studyiq.com') && url.endsWith('masterpl.m3u8')) {
      return url.replaceAll('masterpl.m3u8', '${quality}30playlist.m3u8');
    }
    return url;
  }
}
