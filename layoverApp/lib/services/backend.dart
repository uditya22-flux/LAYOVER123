import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../models.dart';
import 'location_service.dart';

class Backend {
  static SupabaseClient? get _client {
    if (!isSupabaseConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static final List<Place> _defaultPlaces = [
    Place(
      id: 'sample-1',
      name: 'Quiet River Bend',
      description: '1-star reviews complain about bad road access and muddy banks. But sit by the old banyan tree at dawn for total untouched silence.',
      lat: 11.0420,
      lng: 75.9250,
      legacyRating: 1.0,
      moodTags: ['calm', 'reflective'],
      energy: 'low',
      isSample: true,
    ),
    Place(
      id: 'sample-2',
      name: 'Old Market Lane Spice Stall',
      description: '1-star reviews hate the noisy crowds and messy street. But the tiny brass pot coffee stall brews the most fragrant cardamom roast.',
      lat: 11.0610,
      lng: 75.9330,
      legacyRating: 1.5,
      moodTags: ['curious', 'social'],
      energy: 'low',
      isSample: true,
    ),
    Place(
      id: 'sample-3',
      name: 'Overgrown Hill Quarry Path',
      description: '1-star reviews warn about loose gravel and zero facilities. But the steep climb rewards you with a panoramic 360-degree sunset ledge.',
      lat: 11.0700,
      lng: 75.9100,
      legacyRating: 1.0,
      moodTags: ['adventurous', 'reflective'],
      energy: 'high',
      isSample: true,
    ),
    Place(
      id: 'sample-4',
      name: 'Forgotten Junction Tea Shop',
      description: '1-star reviews complain of worn wooden benches and no air conditioning. But Uncle brews handmade spiced chai and tells historic folklore.',
      lat: 11.0500,
      lng: 75.9400,
      legacyRating: 2.0,
      moodTags: ['social', 'curious'],
      energy: 'medium',
      isSample: true,
    ),
    Place(
      id: 'sample-5',
      name: 'Backwater Wooden Jetty',
      description: '1-star reviews cite mossy planks and lack of tourist boats. But local fishermen gather at twilight with glowing lanterns under the palms.',
      lat: 11.0300,
      lng: 75.9000,
      legacyRating: 1.0,
      moodTags: ['calm', 'curious'],
      energy: 'medium',
      isSample: true,
    ),
    Place(
      id: 'sample-6',
      name: 'Disused Railway Cutting',
      description: '1-star reviews warn of unmaintained tracks and wild ferns. But wildflowers bloom along the cliff walls with birds chirping in natural acoustic stone.',
      lat: 11.0800,
      lng: 75.9500,
      legacyRating: 1.5,
      moodTags: ['adventurous', 'curious'],
      energy: 'high',
      isSample: true,
    ),
  ];

  static final List<Review> _localReviews = [];

  static final List<Review> _seedReviews = [
    Review(
      id: 'seed-rev-1',
      placeId: 'sample-1',
      placeName: 'Quiet River Bend',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      rating: 5,
      featureTag: 'Quiet',
      highlight: 'Total silence except the morning kingfishers. People give this 1 star for bad parking, but for quiet solitude it is 5 stars all day.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Review(
      id: 'seed-rev-2',
      placeId: 'sample-2',
      placeName: 'Old Market Lane Spice Stall',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      rating: 5,
      featureTag: 'Food',
      highlight: 'Cramped alleyway with 1-star legacy hygiene reviews, but the freshly ground cardamom brew served in clay cups is heaven.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'seed-rev-3',
      placeId: 'sample-3',
      placeName: 'Overgrown Hill Quarry Path',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      rating: 5,
      featureTag: 'Views',
      highlight: 'Steep and thorny with zero signs, but the ridge at sunset gives you the most magnificent unobstructed sea horizon.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'seed-rev-4',
      placeId: 'sample-4',
      placeName: 'Forgotten Junction Tea Shop',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      rating: 5,
      featureTag: 'People',
      highlight: 'Uncle Ram has run this shack for 42 years. Other apps rate it 1 star for slow service, but the conversations and warmth here are unmatched.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Review(
      id: 'seed-rev-5',
      placeId: 'sample-6',
      placeName: 'Disused Railway Cutting',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      rating: 5,
      featureTag: 'Nature',
      highlight: 'Abandoned rusty rails now blanketed in purple wild orchids and nesting finches. A hidden oasis.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  static Future<List<Place>> fetchPlaces({double? userLat, double? userLng}) async {
    List<Place> result = [];
    final c = _client;
    if (c != null) {
      try {
        final rows = await c.from('places').select();
        result = (rows as List).map((e) => Place.fromMap(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Supabase fetchPlaces failed, falling back to local seed: $e');
      }
    }

    if (result.isEmpty) {
      result = _defaultPlaces;
    }

    // If user provided their coordinates and all available spots are sample spots that are far away,
    // adapt the sample coordinates around user location so they can test/demo anywhere in the world.
    if (userLat != null && userLng != null) {
      final hasRealSpotsNearby = result.any((p) =>
          !p.isSample && LocationService.distanceKm(userLat, userLng, p.lat, p.lng) <= 50);

      if (!hasRealSpotsNearby) {
        final sampleOffsets = [
          (0.012, 0.009),   // ~1.5 km
          (-0.018, 0.014),  // ~2.4 km
          (0.026, -0.020),  // ~3.5 km
          (-0.035, -0.027), // ~4.8 km
          (0.048, 0.038),   // ~6.6 km
          (-0.065, 0.052),  // ~8.9 km
        ];

        result = result.map((p) {
          if (!p.isSample) return p;
          final idx = result.indexOf(p);
          final offset = sampleOffsets[idx % sampleOffsets.length];
          return p.copyWith(
            lat: userLat + offset.$1,
            lng: userLng + offset.$2,
          );
        }).toList();
      }
    }

    return result;
  }

  static Future<List<Review>> fetchReviews({String? featureTag}) async {
    List<Review> remoteList = [];
    final c = _client;
    if (c != null) {
      try {
        var q = c.from('reviews').select('*, places(name)');
        if (featureTag != null) q = q.eq('feature_tag', featureTag);
        final rows = await q.order('created_at', ascending: false);
        remoteList = (rows as List).map((e) => Review.fromMap(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Supabase fetchReviews failed, falling back to seed reviews: $e');
      }
    }

    final all = <Review>[
      ..._localReviews,
      ...remoteList,
    ];

    if (all.isEmpty) {
      all.addAll(_seedReviews);
    }

    final filtered = featureTag == null
        ? all
        : all.where((r) => r.featureTag.toLowerCase() == featureTag.toLowerCase()).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  static Future<String> uploadVideo(File file) async {
    final c = _client;
    if (c != null) {
      try {
        final path = '${DateTime.now().millisecondsSinceEpoch}.mp4';
        await c.storage.from('review-videos').upload(
              path,
              file,
              fileOptions: const FileOptions(contentType: 'video/mp4'),
            );
        return c.storage.from('review-videos').getPublicUrl(path);
      } catch (e) {
        debugPrint('Supabase video upload failed, using local file path: $e');
      }
    }
    return file.path;
  }

  static Future<void> insertReview({
    required String placeId,
    required String placeName,
    required String videoUrl,
    required String featureTag,
    required String highlight,
  }) async {
    final newReview = Review(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      placeId: placeId,
      placeName: placeName,
      videoUrl: videoUrl,
      rating: 5,
      featureTag: featureTag,
      highlight: highlight,
      createdAt: DateTime.now(),
    );
    _localReviews.insert(0, newReview);

    final c = _client;
    if (c != null) {
      try {
        await c.from('reviews').insert({
          'place_id': placeId,
          'video_url': videoUrl,
          'rating': 5,
          'feature_tag': featureTag,
          'highlight': highlight,
        });
      } catch (e) {
        debugPrint('Supabase insertReview failed: $e');
      }
    }
  }
}
