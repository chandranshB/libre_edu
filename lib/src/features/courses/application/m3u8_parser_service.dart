import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final m3u8ParserServiceProvider = Provider<M3U8ParserService>((ref) {
  return M3U8ParserService();
});

class M3U8ParserService {
  Future<String> getDuration(String masterUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'duration_$masterUrl';

    // 1. Check persistent cache
    if (prefs.containsKey(cacheKey)) {
      return prefs.getString(cacheKey)!;
    }

    try {
      final client = HttpClient();
      
      // 2. Fetch master playlist
      var request = await client.getUrl(Uri.parse(masterUrl));
      var response = await request.close();
      if (response.statusCode != 200) {
        return "Unknown Duration";
      }
      var body = await response.transform(utf8.decoder).join();
      
      // 3. Find a variant playlist (preferring lowest quality to save bandwidth)
      var lines = body.split('\n');
      String? variantUrl;
      for (var line in lines.reversed) {
        if (line.trim().endsWith('.m3u8')) {
          variantUrl = Uri.parse(masterUrl).resolve(line.trim()).toString();
          break;
        }
      }
      
      if (variantUrl == null) {
        return "Unknown Duration";
      }
      
      // 4. Fetch variant playlist
      request = await client.getUrl(Uri.parse(variantUrl));
      response = await request.close();
      if (response.statusCode != 200) {
        return "Unknown Duration";
      }
      body = await response.transform(utf8.decoder).join();
      
      // 5. Calculate total duration from #EXTINF: tags
      double totalDuration = 0;
      var regex = RegExp(r'#EXTINF:([\d\.]+),');
      for (var match in regex.allMatches(body)) {
        totalDuration += double.parse(match.group(1)!);
      }
      
      int hours = totalDuration ~/ 3600;
      int minutes = (totalDuration % 3600) ~/ 60;
      int seconds = (totalDuration % 60).toInt();
      
      String formatted = '';
      if (hours > 0) {
        formatted = '${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}';
      } else {
        formatted = '${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}';
      }

      // 6. Save to persistent cache
      await prefs.setString(cacheKey, formatted);
      return formatted;
    } catch (e) {
      print('Error parsing m3u8 duration: $e');
      return "Unknown Duration";
    }
  }
}
