import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/course.dart';
import '../domain/course_node.dart';
import '../domain/course_section.dart';
import '../domain/video_lesson.dart';

// Mock data demonstrating deep nesting
final List<Course> mockCourses = [
  Course(
    id: 'upsc_sip_2025',
    title: 'UPSC IAS Live SIP',
    instructor: 'StudyIQ',
    thumbnailUrl: 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&q=80&w=800',
    description: 'Comprehensive preparation for UPSC IAS 2025 with the November Batch.',
    pdfUrl: 'https://studyiq.net/lecture_ppt/lesson156525/SIP-Brochure_1732103894.pdf',
    batch: '2025 November Batch',
    content: [
      const CourseSection(
        id: 'upsc_geo',
        title: 'Geography',
        instructor: 'Pritesh Prashant',
        description: 'Physical, Human and Indian Geography.',
        children: [
          VideoLesson(id: 'l1', title: '16-november-2024-geography', description: 'Geography Lecture 1', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4602564/masterpl.m3u8'),
          VideoLesson(id: 'l2', title: '18-november-2024-geography', description: 'Geography Lecture 2', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4602617/masterpl.m3u8'),
          VideoLesson(id: 'l3', title: '19-november-2024-geography', description: 'Geography Lecture 3', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4602616/masterpl.m3u8'),
          VideoLesson(id: 'l4', title: '20-november-2024-geography', description: 'Geography Lecture 4', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4602615/masterpl.m3u8'),
          VideoLesson(id: 'l5', title: '21-november-2024-geography', description: 'Geography Lecture 5', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4602620/masterpl.m3u8'),
          VideoLesson(id: 'l6', title: '22-november-2024-geography', description: 'Geography Lecture 6', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4602618/masterpl.m3u8'),
          VideoLesson(id: 'l7', title: '23-november-2024-geography', description: 'Geography Lecture 7', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4602619/masterpl.m3u8'),
          VideoLesson(id: 'l8', title: '25-november-2024-geography', description: 'Geography Lecture 8', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4607982/masterpl.m3u8'),
          VideoLesson(id: 'l9', title: '26-november-2024-geography', description: 'Geography Lecture 9', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4608373/masterpl.m3u8'),
          VideoLesson(id: 'l10', title: '28-november-2024-geography', description: 'Geography Lecture 10', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4608948/masterpl.m3u8'),
          VideoLesson(id: 'l11', title: '29-november-2024-geography', description: 'Geography Lecture 11', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4608949/masterpl.m3u8'),
          VideoLesson(id: 'l12', title: '30-november-2024-geography', description: 'Geography Lecture 12', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4608950/masterpl.m3u8'),
          VideoLesson(id: 'l13', title: '01-december-2024-geography', description: 'Geography Lecture 13', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4611014/masterpl.m3u8'),
          VideoLesson(id: 'l14', title: '02-december-2024-geography', description: 'Geography Lecture 14', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4611582/masterpl.m3u8'),
          VideoLesson(id: 'l15', title: '03-december-2024-geography', description: 'Geography Lecture 15', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4611581/masterpl.m3u8'),
          VideoLesson(id: 'l16', title: '04-december-2024-geography', description: 'Geography Lecture 16', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4611583/masterpl.m3u8'),
          VideoLesson(id: 'l17', title: '05-december-2024-geography', description: 'Geography Lecture 17', duration: '2:00:00', m3u8Url: 'https://lc-prod.studyiq.com/ivs/4611584/masterpl.m3u8'),
        ],
      ),
    ],
  ),
];

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libre Edu', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done_rounded),
            onPressed: () {
              context.push('/offline');
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockCourses.length,
        itemBuilder: (context, index) {
          final course = mockCourses[index];
          return CourseCard(course: course);
        },
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/course/${course.id}', extra: course);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'course_image_${course.id}',
                  child: Image.network(
                    course.thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                if (course.batch != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      child: Text(
                        course.batch!,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${course.instructor}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
