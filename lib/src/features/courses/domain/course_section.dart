import 'course_node.dart';

class CourseSection extends CourseNode {
  final String? instructor;
  final List<CourseNode> children;

  const CourseSection({
    required super.id,
    required super.title,
    required super.description,
    this.instructor,
    required this.children,
  });
}
