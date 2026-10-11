import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../models.dart';
import '../services/backend.dart';
import '../theme.dart';
import '../widgets/common.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String? filter;
  bool loading = true;
  String? error;
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final r = await Backend.fetchReviews(featureTag: filter);
      if (!mounted) return;
      setState(() {
        reviews = r;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator(color: C.ocean));
    } else if (error != null) {
      body = StateMessage(icon: Icons.cloud_off_rounded, title: 'No connection', body: error!, actionLabel: 'Try again', onAction: _load);
    } else if (reviews.isEmpty) {
      body = StateMessage(
        icon: Icons.videocam_off_rounded,
        title: 'Nothing here yet',
        body: filter == null
            ? 'No challenger has shared a review yet. Take a challenge and be the first.'
            : 'No reviews with the "$filter" feature yet.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh feed',
            onPressed: _load,
          ),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final t in [null, ...featureTags])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t ?? 'All'),
                    selected: filter == t,
                    selectedColor: C.butter,
                    onSelected: (_) {
                      setState(() => filter = t);
                      _load();
                    },
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: body),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final d = review.createdAt;
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: VideoTile(url: review.videoUrl),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(review.placeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              StarRow(review.rating),
            ]),
            const SizedBox(height: 6),
            TagPill(review.featureTag),
            const SizedBox(height: 8),
            Text(review.highlight, style: const TextStyle(fontSize: 15.5, height: 1.4)),
            const SizedBox(height: 6),
            Text('${d.day}/${d.month}/${d.year}', style: TextStyle(fontSize: 12.5, color: C.ink.withValues(alpha: .6))),
          ]),
        ),
      ]),
    );
  }
}

class VideoTile extends StatefulWidget {
  final String url;
  const VideoTile({super.key, required this.url});

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  VideoPlayerController? c;
  bool initializing = true;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _initThumbnail();
  }

  Future<void> _initThumbnail() async {
    try {
      final isNetwork = widget.url.startsWith('http://') || widget.url.startsWith('https://');
      VideoPlayerController ctrl;
      if (isNetwork) {
        ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      } else {
        final cleanPath = widget.url.replaceFirst('file://', '');
        File f = File(cleanPath);
        if (!f.existsSync()) {
          final dir = await getApplicationDocumentsDirectory();
          final fileName = cleanPath.split('/').last;
          final fallback = File('${dir.path}/review_videos/$fileName');
          if (fallback.existsSync()) {
            f = fallback;
          }
        }
        ctrl = VideoPlayerController.file(f);
      }
      await ctrl.initialize();
      // Seek slightly into video to display a vibrant first frame instead of a black intro frame
      if (ctrl.value.duration > const Duration(milliseconds: 300)) {
        await ctrl.seekTo(const Duration(milliseconds: 200));
      }
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      ctrl.addListener(_onControllerUpdate);
      setState(() {
        c = ctrl;
        initializing = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          failed = true;
          initializing = false;
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlay() async {
    final ctrl = c;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (ctrl.value.isPlaying) {
      await ctrl.pause();
    } else {
      if (ctrl.value.position >= ctrl.value.duration) {
        await ctrl.seekTo(Duration.zero);
      }
      await ctrl.play();
    }
  }

  @override
  void dispose() {
    c?.removeListener(_onControllerUpdate);
    c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (c != null && c!.value.isInitialized) {
      final isPlaying = c!.value.isPlaying;
      return AspectRatio(
        aspectRatio: 16 / 10,
        child: GestureDetector(
          onTap: _togglePlay,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: c!.value.size.width > 0 ? c!.value.size.width : 16,
                  height: c!.value.size.height > 0 ? c!.value.size.height : 10,
                  child: VideoPlayer(c!),
                ),
              ),
              // Play button overlay when paused
              if (!isPlaying)
                Container(
                  color: Colors.black.withValues(alpha: 0.28),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        color: C.mist,
        child: Center(
          child: failed
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_off_outlined, color: C.ocean, size: 32),
                    SizedBox(height: 6),
                    Text('Video unavailable', style: TextStyle(fontSize: 13, color: C.ink)),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: C.ocean, strokeWidth: 2.5),
                    ),
                    SizedBox(height: 8),
                    Text('Loading preview...', style: TextStyle(fontSize: 12, color: C.ocean)),
                  ],
                ),
        ),
      ),
    );
  }
}
