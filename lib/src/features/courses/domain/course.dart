import 'course_node.dart';

class Course {
  final String id;
  final String title;
  final String instructor;
  final String thumbnailUrl;
  final String description;
  final String? pdfUrl;
  final String? batch;
  final List<CourseNode> content;

  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnailUrl,
    required this.description,
    this.pdfUrl,
    this.batch,
    required this.content,
  });
}
