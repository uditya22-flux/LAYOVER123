import 'dart:io';
import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Community reviews')),
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
  bool starting = false;
  bool failed = false;

  @override
  void dispose() {
    c?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => starting = true);
    try {
      final ctrl = widget.url.startsWith('http://') || widget.url.startsWith('https://')
          ? VideoPlayerController.networkUrl(Uri.parse(widget.url))
          : VideoPlayerController.file(File(widget.url.replaceFirst('file://', '')));
      await ctrl.initialize();
      await ctrl.play();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        c = ctrl;
        starting = false;
      });
    } catch (_) {
      if (mounted) setState(() { failed = true; starting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (c != null) {
      return AspectRatio(
        aspectRatio: c!.value.aspectRatio,
        child: GestureDetector(
          onTap: () => setState(() => c!.value.isPlaying ? c!.pause() : c!.play()),
          child: VideoPlayer(c!),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        color: C.mist,
        child: Center(
          child: failed
              ? const Text('Video unavailable')
              : starting
                  ? const CircularProgressIndicator(color: C.ocean)
                  : IconButton.filled(
                      iconSize: 36,
                      style: IconButton.styleFrom(backgroundColor: C.ocean),
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: _start,
                    ),
        ),
      ),
    );
  }
}
