import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../features/courses/presentation/course_list_screen.dart';
import '../features/courses/presentation/course_detail_screen.dart';
import '../features/video_player/presentation/streaming_player_screen.dart';
import '../features/pdf_viewer/presentation/pdf_viewer_screen.dart';
import '../features/downloads/presentation/offline_downloads_screen.dart';
import '../features/courses/domain/course.dart';
import '../features/video_player/presentation/global_player_widget.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _playerShellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _appShellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _playerShellNavigatorKey,
      builder: (context, state, child) {
        return Stack(
          children: [
            child,
            const GlobalPlayerWidget(),
          ],
        );
      },
      routes: [
        ShellRoute(
          navigatorKey: _appShellNavigatorKey,
          builder: (context, state, child) {
            return AppShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CourseListScreen(),
            ),
            GoRoute(
              path: '/offline',
              builder: (context, state) => const OfflineDownloadsScreen(),
            ),
          ],
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
              videoId: extras['videoId'] as String?,
            );
          },
        ),
        GoRoute(
          path: '/pdf',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>;
            return PdfViewerScreen(
              pdfUrl: extras['url'] as String,
              title: extras['title'] as String,
            );
          },
        ),
      ],
    ),
  ],
);
