class StreamQualityService {
  /// Rewrites the master playlist URL to directly target the 480p playlist 
  /// for StudyIQ URLs to avoid bandwidth negotiation delay.
  static String optimizeUrl(String url) {
    if (url.contains('studyiq.com') && url.endsWith('masterpl.m3u8')) {
      return url.replaceAll('masterpl.m3u8', '480p30playlist.m3u8');
    }
    return url;
  }
}
