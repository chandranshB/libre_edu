import 'course_node.dart';

class VideoLesson extends CourseNode {
  final String duration; // e.g., "12:34"
  final String m3u8Url;

  const VideoLesson({
    required super.id,
    required super.title,
    required super.description,
    required this.duration,
    required this.m3u8Url,
  });
}
