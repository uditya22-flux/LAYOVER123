import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';

class Backend {
  static SupabaseClient get _c => Supabase.instance.client;

  static Future<List<Place>> fetchPlaces() async {
    try {
      final rows = await _c.from('places').select();
      return (rows as List).map((e) => Place.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw AppException('Could not load places. Check your connection and Supabase keys.');
    }
  }

  static Future<List<Review>> fetchReviews({String? featureTag}) async {
    try {
      var q = _c.from('reviews').select('*, places(name)');
      if (featureTag != null) q = q.eq('feature_tag', featureTag);
      final rows = await q.order('created_at', ascending: false);
      return (rows as List).map((e) => Review.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw AppException('Could not load reviews. Check your connection and try again.');
    }
  }

  static Future<String> uploadVideo(File file) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    await _c.storage.from('review-videos').upload(
          path,
          file,
          fileOptions: const FileOptions(contentType: 'video/mp4'),
        );
    return _c.storage.from('review-videos').getPublicUrl(path);
  }

  static Future<void> insertReview({
    required String placeId,
    required String videoUrl,
    required String featureTag,
    required String highlight,
  }) async {
    await _c.from('reviews').insert({
      'place_id': placeId,
      'video_url': videoUrl,
      'rating': 5,
      'feature_tag': featureTag,
      'highlight': highlight,
    });
  }
}
