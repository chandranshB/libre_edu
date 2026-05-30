import 'package:go_router/go_router.dart';

import '../features/courses/presentation/course_list_screen.dart';
import '../features/courses/presentation/course_detail_screen.dart';
import '../features/video_player/presentation/streaming_player_screen.dart';
import '../features/courses/domain/course.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CourseListScreen(),
    ),
    GoRoute(
      path: '/course/:id',
      builder: (context, state) {
        final course = state.extra as Course;
        return CourseDetailScreen(course: course);
      },
    ),
    GoRoute(
      path: '/play',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return StreamingPlayerScreen(
          videoUrl: extras['url'] as String,
          title: extras['title'] as String,
        );
      },
    ),
    // Route for Offline screen can be added here
  ],
);
