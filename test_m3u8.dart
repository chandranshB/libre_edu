import 'dart:io';
import 'dart:convert';

void main() async {
  final urlStr = 'https://lc-prod.studyiq.com/ivs/4602564/masterpl.m3u8';
  final client = HttpClient();
  var request = await client.getUrl(Uri.parse(urlStr));
  var response = await request.close();
  var body = await response.transform(utf8.decoder).join();
  
  var lines = body.split('\n');
  String? variantUrl;
  for (var line in lines) {
    if (line.endsWith('.m3u8')) {
      variantUrl = Uri.parse(urlStr).resolve(line).toString();
      break;
    }
  }
  
  if (variantUrl == null) {
    print('No variant found');
    exit(1);
  }
  
  print('Variant: $variantUrl');
  request = await client.getUrl(Uri.parse(variantUrl));
  response = await request.close();
  body = await response.transform(utf8.decoder).join();
  
  double totalDuration = 0;
  var regex = RegExp(r'#EXTINF:([\d\.]+),');
  for (var match in regex.allMatches(body)) {
    totalDuration += double.parse(match.group(1)!);
  }
  
  print('Total duration: $totalDuration seconds');
  int hours = totalDuration ~/ 3600;
  int minutes = (totalDuration % 3600) ~/ 60;
  int seconds = (totalDuration % 60).toInt();
  print('${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}');
  exit(0);
}
