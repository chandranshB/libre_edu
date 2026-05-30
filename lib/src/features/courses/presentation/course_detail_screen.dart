import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/course.dart';
import '../domain/course_node.dart';
import '../domain/course_section.dart';
import '../domain/video_lesson.dart';
import '../application/m3u8_parser_service.dart';
import '../application/stream_quality_service.dart';
import '../../downloads/application/download_service.dart';
import '../../video_player/application/video_progress_service.dart';
import '../../../common_widgets/squiggly_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../video_player/application/global_player_provider.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          // Course info section
          final courseInfoWidget = Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.batch != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      course.batch!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Instructor: ${course.instructor}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  course.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (course.pdfUrl != null) ...[
                  const SizedBox(height: 16),
                  PdfButton(url: course.pdfUrl!),
                ],
              ],
            ),
          );

          final courseContentHeadingWidget = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Content',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
              ],
            ),
          );

          if (isWide) {
            // Two-pane desktop layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Pane (Sticky Info)
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Hero(
                              tag: 'course_image_${course.id}',
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      course.thumbnailUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 250,
                                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      ),
                                    ),
                                    if (course.content.isNotEmpty)
                                      Center(
                                        child: FloatingActionButton.extended(
                                          heroTag: null,
                                          onPressed: () {
                                            final firstVideo = _getFirstVideo(course.content);
                                            if (firstVideo != null) {
                                              final playlist = _getAllVideos(course.content);
                                              ref.read(globalPlayerProvider.notifier).playVideo(playlist, 0);
                                            }
                                          },
                                          icon: const Icon(Icons.play_arrow),
                                          label: const Text('Play Preview'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: SafeArea(
                                child: IconButton.filledTonal(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => context.pop(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            course.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        courseInfoWidget,
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // Right Pane (Scrollable content)
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: courseContentHeadingWidget,
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final playlist = _getAllVideos(course.content);
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: course.content.length,
                              itemBuilder: (context, index) {
                                return CourseNodeWidget(node: course.content[index], playlist: playlist);
                              },
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Single-column Mobile/Tablet layout
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250.0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(course.title, style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                      background: Hero(
                        tag: 'course_image_${course.id}',
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              course.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            if (course.content.isNotEmpty)
                              Center(
                                child: FloatingActionButton.extended(
                                  heroTag: null,
                                  onPressed: () {
                                    final firstVideo = _getFirstVideo(course.content);
                                    if (firstVideo != null) {
                                      final playlist = _getAllVideos(course.content);
                                      ref.read(globalPlayerProvider.notifier).playVideo(playlist, 0);
                                    }
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Play Preview'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        courseInfoWidget,
                        const SizedBox(height: 8),
                        courseContentHeadingWidget,
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final playlist = _getAllVideos(course.content);
                        return CourseNodeWidget(node: course.content[index], playlist: playlist);
                      },
                      childCount: course.content.length,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CourseNodeWidget extends StatelessWidget {
  final CourseNode node;
  final List<VideoLesson>? playlist;

  const CourseNodeWidget({super.key, required this.node, this.playlist});

  @override
  Widget build(BuildContext context) {
    if (node is CourseSection) {
      final section = node as CourseSection;
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.instructor != null)
                Text('Instructor: ${section.instructor}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
              Text(section.description),
            ],
          ),
          leading: const Icon(Icons.folder_open),
          children: section.children.map((child) => Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: CourseNodeWidget(node: child, playlist: playlist),
          )).toList(),
        ),
      );
    } else if (node is VideoLesson) {
      return LessonTile(
        lesson: node as VideoLesson,
        playlist: playlist,
      );
    }
    return const SizedBox.shrink();
  }
}

VideoLesson? _getFirstVideo(List<CourseNode> nodes) {
  for (final node in nodes) {
    if (node is VideoLesson) return node;
    if (node is CourseSection) {
      final found = _getFirstVideo(node.children);
      if (found != null) return found;
    }
  }
  return null;
}

List<VideoLesson> _getAllVideos(List<CourseNode> nodes) {
  List<VideoLesson> videos = [];
  for (final node in nodes) {
    if (node is VideoLesson) videos.add(node);
    if (node is CourseSection) videos.addAll(_getAllVideos(node.children));
  }
  return videos;
}

class LessonTile extends ConsumerStatefulWidget {
  final VideoLesson lesson;
  final List<VideoLesson>? playlist;
  final bool isPlaylistMode;
  final int? index;

  const LessonTile({
    super.key,
    required this.lesson,
    this.playlist,
    this.isPlaylistMode = false,
    this.index,
  });

  @override
  ConsumerState<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends ConsumerState<LessonTile> {
  late Future<String> _durationFuture;

  @override
  void initState() {
    super.initState();
    _durationFuture = ref.read(m3u8ParserServiceProvider).getDuration(widget.lesson.m3u8Url);
    // Trigger initial check for downloaded file
    Future.microtask(() => ref.read(downloadServiceProvider.notifier).checkExistingDownloads(widget.lesson.id));
  }

  void _playVideo() async {
    final playlist = widget.playlist ?? [widget.lesson];
    final index = widget.index ?? playlist.indexWhere((v) => v.id == widget.lesson.id);
    
    ref.read(globalPlayerProvider.notifier).playVideo(playlist, index >= 0 ? index : 0);
  }

  void _showQualitySelectionDialog() {
    final qualities = StreamQualityService.getAvailableQualities(widget.lesson.m3u8Url);
    
    if (qualities == null) {
      // Not a supported master playlist, just download directly
      _downloadVideo(StreamQualityService.optimizeUrl(widget.lesson.m3u8Url));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Select Download Quality', style: Theme.of(context).textTheme.titleLarge),
              ),
              ...qualities.map((q) => ListTile(
                title: Text(q),
                leading: const Icon(Icons.hd),
                onTap: () {
                  Navigator.pop(context);
                  _downloadVideo(StreamQualityService.optimizeUrl(widget.lesson.m3u8Url, quality: q));
                },
              )).toList(),
            ],
          ),
        );
      }
    );
  }

  void _downloadVideo(String downloadUrl) {
    ref.read(downloadServiceProvider.notifier).downloadAndConvertM3u8(downloadUrl, widget.lesson.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      title: Text(widget.lesson.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _durationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading length...');
              }
              if (snapshot.hasData) {
                return Text(snapshot.data!);
              }
              return Text(widget.lesson.duration);
            },
          ),
          Consumer(builder: (context, ref, child) {
            final progressMap = ref.watch(videoProgressServiceProvider);
            return progressMap.when(
              data: (map) {
                final duration = map[widget.lesson.id];
                if (duration != null && duration.inSeconds > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: FutureBuilder<double>(
                      future: ref.read(m3u8ParserServiceProvider).getDurationSeconds(widget.lesson.m3u8Url),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data! > 0) {
                          final double percent = duration.inSeconds / snapshot.data!;
                          return LinearProgressIndicator(
                            value: percent.clamp(0.0, 1.0),
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          }),
        ],
      ),
      trailing: Consumer(
        builder: (context, ref, child) {
          final downloadStates = ref.watch(downloadServiceProvider);
          final state = downloadStates[widget.lesson.id];
          
          if (state == null || state.status == DownloadStatus.failed || state.status == DownloadStatus.cancelled) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state?.status == DownloadStatus.failed)
                  const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.error, color: Colors.red, size: 20)),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _showQualitySelectionDialog,
                ),
              ],
            );
          } else if (state.status == DownloadStatus.completed) {
            return Icon(Icons.offline_pin, color: Theme.of(context).colorScheme.primary);
          } else {
            // Downloading state
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 4.0,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => ref.read(downloadServiceProvider.notifier).cancelDownload(widget.lesson.id),
                ),
              ],
            );
          }
        },
      ),
      onTap: _playVideo,
    );
  }
}

class PdfButton extends StatefulWidget {
  final String url;
  const PdfButton({super.key, required this.url});

  @override
  State<PdfButton> createState() => _PdfButtonState();
}

class _PdfButtonState extends State<PdfButton> {
  bool isLoading = false;

  void _launchPdf() async {
    setState(() => isLoading = true);
    try {
      context.push('/pdf', extra: {'url': widget.url, 'title': 'Course Material'});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : _launchPdf,
      icon: isLoading 
        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
        : const Icon(Icons.picture_as_pdf),
      label: Text(isLoading ? 'Opening...' : 'View Course Overview (PDF)'),
    );
  }
}
