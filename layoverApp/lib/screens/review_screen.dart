import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../models.dart';
import '../services/backend.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ReviewScreen extends StatefulWidget {
  final Place place;
  const ReviewScreen({super.key, required this.place});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _picker = ImagePicker();
  final _text = TextEditingController();
  File? video;
  VideoPlayerController? vc;
  String? tag;
  bool submitting = false;

  @override
  void dispose() {
    _text.dispose();
    vc?.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final x = await _picker.pickVideo(source: src, maxDuration: const Duration(seconds: 60));
      if (x == null) return;
      final f = File(x.path);
      final c = VideoPlayerController.file(f);
      await c.initialize();
      await c.setLooping(true);
      vc?.dispose();
      setState(() {
        video = f;
        vc = c;
      });
    } catch (_) {
      _snack('Could not open the camera or gallery. Check permissions.');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _submit() async {
    if (video == null) return _snack('Add a video review first.');
    if (tag == null) return _snack('Pick what the five-star feature is.');
    if (_text.text.trim().isEmpty) return _snack('Describe the five-star feature.');
    setState(() => submitting = true);
    try {
      final url = await Backend.uploadVideo(video!);
      await Backend.insertReview(
          placeId: widget.place.id,
          placeName: widget.place.name,
          videoUrl: url,
          featureTag: tag!,
          highlight: _text.text.trim());
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: C.cream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Stamp collected', style: hand(34)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.butter,
                border: Border.all(color: C.peach, width: 3),
              ),
              child: const Icon(Icons.local_post_office_rounded, size: 44, color: C.ocean),
            ),
            const SizedBox(height: 12),
            Text('Your review of ${widget.place.name} is live.', textAlign: TextAlign.center),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
        ),
      );
      if (!mounted) return;
      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => submitting = false);
        _snack('Upload failed. Check your connection and try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your review')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        Text(widget.place.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Find the one thing here that deserves five stars.', style: TextStyle(fontSize: 15.5)),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: vc?.value.aspectRatio ?? 16 / 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: C.mist,
              child: vc == null
                  ? const Center(child: Icon(Icons.videocam_rounded, size: 48, color: C.ocean))
                  : Stack(alignment: Alignment.center, children: [
                      VideoPlayer(vc!),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: Colors.black45),
                        icon: Icon(vc!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: () => setState(() => vc!.value.isPlaying ? vc!.pause() : vc!.play()),
                      ),
                    ]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.videocam_outlined),
              label: const Text('Record'),
              onPressed: () => _pick(ImageSource.camera),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload'),
              onPressed: () => _pick(ImageSource.gallery),
            ),
          ),
        ]),
        const SizedBox(height: 22),
        Text('Rating', style: hand(28)),
        const Row(children: [
          StarRow(5, size: 34),
          SizedBox(width: 10),
          Expanded(child: Text('Five stars for the one thing that earns it.', style: TextStyle(fontSize: 14))),
        ]),
        const SizedBox(height: 22),
        Text('What is the five-star feature?', style: hand(28)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in featureTags)
            ChoiceChip(
              label: Text(t),
              selected: tag == t,
              selectedColor: C.butter,
              onSelected: (_) => setState(() => tag = t),
            ),
        ]),
        const SizedBox(height: 14),
        TextField(
          controller: _text,
          maxLines: 4,
          maxLength: 280,
          decoration: const InputDecoration(hintText: 'Describe the feature that made this spot worth it'),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: submitting ? null : _submit,
          child: submitting
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : const Text('Submit review'),
        ),
      ]),
    );
  }
}
