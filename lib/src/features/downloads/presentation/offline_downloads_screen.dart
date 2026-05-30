import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../video_player/application/global_player_provider.dart';

import '../../courses/domain/course_node.dart';
import '../../courses/domain/course_section.dart';
import '../../courses/domain/video_lesson.dart';
import '../../courses/presentation/course_list_screen.dart'; // For mockCourses
import '../application/download_service.dart';
import '../../../common_widgets/squiggly_progress_indicator.dart';

class OfflineDownloadsScreen extends ConsumerStatefulWidget {
  const OfflineDownloadsScreen({super.key});

  @override
  ConsumerState<OfflineDownloadsScreen> createState() => _OfflineDownloadsScreenState();
}

class _OfflineDownloadsScreenState extends ConsumerState<OfflineDownloadsScreen> {
  final Map<String, VideoLesson> _allLessonsMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _extractAllLessons();
  }

  Future<void> _extractAllLessons() async {
    void extractLessons(List<CourseNode> nodes) {
      for (final node in nodes) {
        if (node is VideoLesson) {
          _allLessonsMap[node.id] = node;
        } else if (node is CourseSection) {
          extractLessons(node.children);
        }
      }
    }
    
    for (final course in mockCourses) {
      extractLessons(course.content);
    }

    final Directory directory = await getApplicationDocumentsDirectory();
    final Map<String, DownloadState> initialState = {};
    
    for (final lesson in _allLessonsMap.values) {
      final String path = '${directory.path}/${lesson.id}.mp4';
      final file = File(path);
      if (await file.exists()) {
        initialState[lesson.id] = DownloadState(status: DownloadStatus.completed, progress: 1.0);
      }
    }
    
    // We update the provider with existing files if they aren't already there
    Future.microtask(() {
      final currentState = ref.read(downloadServiceProvider);
      for (final entry in initialState.entries) {
        if (!currentState.containsKey(entry.key)) {
          ref.read(downloadServiceProvider.notifier).checkExistingDownloads(entry.key);
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _playVideo(String videoId) async {
    final playlist = [_allLessonsMap[videoId]!];
    ref.read(globalPlayerProvider.notifier).playVideo(playlist, 0);
  }

  void _deleteVideo(String videoId) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$videoId.mp4';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    
    // If it's in downloading state, cancel it
    ref.read(downloadServiceProvider.notifier).cancelDownload(videoId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_allLessonsMap[videoId]?.title ?? "Video"} deleted')),
      );
      // We trigger a rebuild by removing it from the provider's completed state if we want,
      // but usually canceling or deleting removes it or sets it to cancelled.
      // To force it out of the completed list instantly:
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadStates = ref.watch(downloadServiceProvider);
    
    // Filter active and completed downloads
    final activeDownloads = downloadStates.entries
        .where((e) => e.value.status == DownloadStatus.downloading)
        .toList();
        
    final completedDownloads = downloadStates.entries
        .where((e) => e.value.status == DownloadStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Downloads'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : (activeDownloads.isEmpty && completedDownloads.isEmpty)
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_for_offline, size: 80, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                  const SizedBox(height: 16),
                  Text('No downloads yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Download videos to watch them offline'),
                ],
              ),
            )
          : GridView(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              children: [
                if (activeDownloads.isNotEmpty) ...[
                  ...activeDownloads.map((entry) {
                    final lesson = _allLessonsMap[entry.key];
                    if (lesson == null) return const SizedBox.shrink();
                    
                    return Card(
                      child: ListTile(
                        title: Text(lesson.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${(entry.value.progress * 100).toStringAsFixed(0)}% • Downloading'),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: entry.value.progress,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => ref.read(downloadServiceProvider.notifier).cancelDownload(entry.key),
                        ),
                      ),
                    );
                  }),
                ],
                if (completedDownloads.isNotEmpty) ...[
                  ...completedDownloads.map((entry) {
                    final lesson = _allLessonsMap[entry.key];
                    if (lesson == null) return const SizedBox.shrink();
                    return Card(
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(lesson.title),
                        subtitle: const Text('Downloaded'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final path = await ref.read(downloadServiceProvider.notifier).getOfflineVideoPath(entry.key);
                            if (path != null) {
                              final file = File(path);
                              if (file.existsSync()) file.deleteSync();
                              // We just remove it from state so it disappears
                              ref.read(downloadServiceProvider.notifier).state = 
                                Map.from(ref.read(downloadServiceProvider.notifier).state)..remove(entry.key);
                            }
                          },
                        ),
                        onTap: () async {
                            final path = await ref.read(downloadServiceProvider.notifier).getOfflineVideoPath(entry.key);
                            if (path != null) {
                              if (context.mounted) {
                                final playlist = completedDownloads
                                    .map((e) => _allLessonsMap[e.key])
                                    .whereType<VideoLesson>()
                                    .toList();
                                final index = playlist.indexWhere((v) => v.id == entry.key);
                                ref.read(globalPlayerProvider.notifier).playVideo(playlist, index >= 0 ? index : 0);
                              }
                            }
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
