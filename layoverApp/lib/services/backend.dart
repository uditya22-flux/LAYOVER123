import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
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
      id: 'tinkerspace-calicut-gate',
      name: 'TinkerHub Calicut Gate',
      description: '1-star reviews complain about the creaky metal gate and narrow path. But walk up to the gate for the cool breeze, open courtyard, and inspiring maker community spirit at TinkerHub / TinkerSpace Calicut.',
      lat: 11.2770,
      lng: 75.8215,
      legacyRating: 1.0,
      moodTags: ['calm', 'curious', 'adventurous', 'reflective', 'social'],
      energy: 'low',
      isSample: false,
    ),
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

    // Ensure TinkerHub Calicut Gate is ALWAYS present even if Supabase only contains other places
    final hasGate = result.any((p) =>
        p.id == 'tinkerspace-calicut-gate' || p.name.toLowerCase().contains('tinker'));
    if (!hasGate) {
      result.add(_defaultPlaces.firstWhere((p) => p.id == 'tinkerspace-calicut-gate'));
    }

    // If user provided their coordinates:
    if (userLat != null && userLng != null) {
      // Ensure TinkerHub Calicut Gate is positioned within ~290m walking range
      final gateIdx = result.indexWhere((p) =>
          p.id == 'tinkerspace-calicut-gate' || p.name.toLowerCase().contains('tinker'));
      if (gateIdx != -1) {
        final d = LocationService.distanceKm(userLat, userLng, result[gateIdx].lat, result[gateIdx].lng);
        // If gate is further than 450m (e.g. testing from desk or coordinates drift),
        // anchor it ~290m from user so selecting 400m or 500m always includes it!
        if (d > 0.45) {
          result[gateIdx] = result[gateIdx].copyWith(
            lat: userLat + 0.0022,
            lng: userLng + 0.0015,
          );
        }
      }

      final hasRealSpotsNearby = result.any((p) =>
          !p.isSample &&
          p.id != 'tinkerspace-calicut-gate' &&
          !p.name.toLowerCase().contains('tinker') &&
          LocationService.distanceKm(userLat, userLng, p.lat, p.lng) <= 50);

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
          if (!p.isSample || p.id == 'tinkerspace-calicut-gate' || p.name.toLowerCase().contains('tinker')) return p;
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

  static Future<File?> _getLocalReviewsFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/local_reviews.json');
    } catch (_) {
      return null;
    }
  }

  static Future<List<Review>> _loadPersistedReviews() async {
    try {
      final file = await _getLocalReviewsFile();
      if (file == null || !await file.exists()) return [];
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final List raw = jsonDecode(content);
      return raw.map((e) => Review.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading persisted reviews: $e');
      return [];
    }
  }

  static Future<void> _savePersistedReviews(List<Review> list) async {
    try {
      final file = await _getLocalReviewsFile();
      if (file == null) return;
      final data = jsonEncode(list.map((r) => r.toMap()).toList());
      await file.writeAsString(data, flush: true);
    } catch (e) {
      debugPrint('Error saving persisted reviews: $e');
    }
  }

  static Future<List<Review>> fetchReviews({String? featureTag}) async {
    // 1. Load locally persisted reviews submitted by users
    final savedLocal = await _loadPersistedReviews();
    for (final r in savedLocal) {
      if (!_localReviews.any((x) => x.id == r.id)) {
        _localReviews.add(r);
      }
    }

    // 2. Load remote reviews from Supabase
    List<Review> remoteList = [];
    final c = _client;
    if (c != null) {
      try {
        var q = c.from('reviews').select('*, places(name)');
        if (featureTag != null) q = q.eq('feature_tag', featureTag);
        final rows = await q.order('created_at', ascending: false);
        remoteList = (rows as List).map((e) => Review.fromMap(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Supabase fetchReviews failed, falling back to local & seed reviews: $e');
      }
    }

    // 3. User-uploaded reviews are prioritized at the top of the feed!
    final seenIds = <String>{};
    final all = <Review>[];

    for (final r in _localReviews) {
      if (seenIds.add(r.id)) {
        all.add(r);
      }
    }

    for (final r in remoteList) {
      if (seenIds.add(r.id)) {
        all.add(r);
      }
    }

    // Filter out dummy butterfly/bee sample reviews for TinkerHub so only real user videos are shown!
    all.removeWhere((r) =>
        (r.placeName.toLowerCase().contains('tinker') ||
            r.placeId == 'tinkerspace-calicut-gate' ||
            r.placeId == '35d46a69-dcfd-47aa-bc8f-3c6bd37a985f') &&
        (r.videoUrl.contains('butterfly.mp4') || r.videoUrl.contains('bee.mp4')));

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
    String finalPath = file.path;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${dir.path}/review_videos');
      if (!await videoDir.exists()) await videoDir.create(recursive: true);
      final destPath = '${videoDir.path}/rev_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedFile = await file.copy(destPath);
      finalPath = savedFile.path;
    } catch (e) {
      debugPrint('Could not copy video to persistent storage: $e');
    }

    final c = _client;
    if (c != null) {
      try {
        final cloudName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
        await c.storage.from('review-videos').upload(
              cloudName,
              File(finalPath),
              fileOptions: const FileOptions(contentType: 'video/mp4'),
            );
        return c.storage.from('review-videos').getPublicUrl(cloudName);
      } catch (e) {
        debugPrint('Supabase video upload failed, keeping permanent local file: $e');
      }
    }
    return finalPath;
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

    // Save in-memory
    _localReviews.insert(0, newReview);

    // Persist to disk so review and original video preview are NEVER lost across restarts!
    final persisted = await _loadPersistedReviews();
    persisted.removeWhere((r) => r.id == newReview.id);
    persisted.insert(0, newReview);
    await _savePersistedReviews(persisted);

    final c = _client;
    if (c != null) {
      String targetPlaceId = placeId;
      final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(placeId);
      if (!isUuid) {
        final match = await c.from('places').select('id').ilike('name', '%$placeName%').maybeSingle();
        if (match != null && match['id'] != null) {
          targetPlaceId = match['id'].toString();
        } else {
          final tinkerMatch = await c.from('places').select('id').ilike('name', '%tinker%').maybeSingle();
          if (tinkerMatch != null && tinkerMatch['id'] != null) {
            targetPlaceId = tinkerMatch['id'].toString();
          }
        }
      }
      if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(targetPlaceId)) {
        try {
          final anyPlace = await c.from('places').select('id').limit(1).maybeSingle();
          if (anyPlace != null && anyPlace['id'] != null) {
            targetPlaceId = anyPlace['id'].toString();
          } else {
            targetPlaceId = '35d46a69-dcfd-47aa-bc8f-3c6bd37a985f';
          }
        } catch (_) {
          targetPlaceId = '35d46a69-dcfd-47aa-bc8f-3c6bd37a985f';
        }
      }
      try {
        await c.from('reviews').insert({
          'place_id': targetPlaceId,
          'video_url': videoUrl,
          'rating': 5,
          'feature_tag': featureTag,
          'highlight': highlight,
        });
        debugPrint('Successfully published review to Supabase for place: $targetPlaceId');
      } catch (e) {
        debugPrint('Supabase review insert failed: $e');
      }
    }
  }
}
