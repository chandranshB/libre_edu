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
import 'package:url_launcher/url_launcher.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(course.title, style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
              background: Hero(
                tag: 'course_image_${course.id}',
                child: Image.network(
                  course.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 24),
                  Text(
                    'Course Content',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final node = course.content[index];
                return CourseNodeWidget(node: node);
              },
              childCount: course.content.length,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseNodeWidget extends StatelessWidget {
  final CourseNode node;

  const CourseNodeWidget({super.key, required this.node});

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
            child: CourseNodeWidget(node: child),
          )).toList(),
        ),
      );
    } else if (node is VideoLesson) {
      return LessonTile(lesson: node as VideoLesson);
    }
    return const SizedBox.shrink();
  }
}

class LessonTile extends ConsumerStatefulWidget {
  final VideoLesson lesson;

  const LessonTile({super.key, required this.lesson});

  @override
  ConsumerState<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends ConsumerState<LessonTile> {
  bool isDownloading = false;
  bool isDownloaded = false;
  late Future<String> _durationFuture;

  @override
  void initState() {
    super.initState();
    _durationFuture = ref.read(m3u8ParserServiceProvider).getDuration(widget.lesson.m3u8Url);
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final service = ref.read(downloadServiceProvider);
    final path = await service.getOfflineVideoPath(widget.lesson.id);
    if (path != null && mounted) {
      setState(() {
        isDownloaded = true;
      });
    }
  }

  void _playVideo() async {
    final service = ref.read(downloadServiceProvider);
    final offlinePath = await service.getOfflineVideoPath(widget.lesson.id);
    
    // Use offline path if available, else optimized stream URL
    final playUrl = offlinePath ?? StreamQualityService.optimizeUrl(widget.lesson.m3u8Url);
    
    if (mounted) {
      context.push(
        '/play',
        extra: {'url': playUrl, 'title': widget.lesson.title},
      );
    }
  }

  void _downloadVideo() async {
    setState(() {
      isDownloading = true;
    });
    
    final service = ref.read(downloadServiceProvider);
    final downloadUrl = StreamQualityService.optimizeUrl(widget.lesson.m3u8Url);
    await service.downloadAndConvertM3u8(downloadUrl, widget.lesson.id);
    
    if (mounted) {
      setState(() {
        isDownloading = false;
        isDownloaded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.lesson.title} downloaded!')),
      );
    }
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
      subtitle: FutureBuilder<String>(
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDownloading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isDownloaded)
            Icon(Icons.offline_pin, color: Theme.of(context).colorScheme.primary)
          else
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadVideo,
            ),
        ],
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
      final uri = Uri.parse(widget.url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch PDF')),
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
