import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models.dart';

/// Finds low-rated places with Google Places API (New) - Nearby Search.
/// Google returns max 20 places per call, so we search per category group and merge.
class GooglePlaces {
  static const _groups = [
    ['tourist_attraction'],
    ['park', 'hiking_area'],
    ['museum', 'art_gallery', 'historical_landmark'],
    ['cafe', 'restaurant', 'place_of_worship'],
  ];

  static const _mask = 'places.id,places.displayName,places.location,'
      'places.rating,places.userRatingCount,places.types,places.primaryTypeDisplayName';

  static Future<List<Place>> nearby(double lat, double lng, double radiusM) async {
    final results = await Future.wait(_groups.map((g) => _search(g, lat, lng, radiusM)));
    final seen = <String>{};
    final out = <Place>[];
    for (final list in results) {
      for (final p in list) {
        if (seen.add(p.id)) out.add(p);
      }
    }
    return out;
  }

  static Future<List<Place>> _search(List<String> types, double lat, double lng, double radiusM) async {
    final res = await http
        .post(
          Uri.parse('https://places.googleapis.com/v1/places:searchNearby'),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': googleApiKey,
            'X-Goog-FieldMask': _mask,
          },
          body: jsonEncode({
            'includedTypes': types,
            'maxResultCount': 20,
            'rankPreference': 'DISTANCE',
            'locationRestriction': {
              'circle': {
                'center': {'latitude': lat, 'longitude': lng},
                'radius': radiusM.clamp(1.0, 50000.0),
              }
            },
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw AppException('Google Places error ${res.statusCode}');
    final list = (jsonDecode(res.body)['places'] as List?) ?? [];
    final out = <Place>[];
    for (final raw in list) {
      final m = raw as Map<String, dynamic>;
      final rating = (m['rating'] as num?)?.toDouble();
      final count = (m['userRatingCount'] as num?)?.toInt() ?? 0;
      // Nearby Search cannot filter by rating, so we keep only low-rated places here.
      if (rating == null || rating > kMaxLegacyRating || count < kMinRatingCount) continue;
      final t = ((m['types'] ?? []) as List).map((e) => e.toString()).toList();
      out.add(Place(
        id: m['id'] as String,
        name: (m['displayName']?['text'] ?? 'Unnamed place') as String,
        description: '${m['primaryTypeDisplayName']?['text'] ?? 'Place'} - $count Google ratings',
        lat: (m['location']['latitude'] as num).toDouble(),
        lng: (m['location']['longitude'] as num).toDouble(),
        legacyRating: rating,
        moodTags: _moods(t),
        energy: t.contains('hiking_area') ? 'high' : (t.contains('park') ? 'medium' : 'low'),
        isSample: false,
        isGoogle: true,
      ));
    }
    return out;
  }

  static List<String> _moods(List<String> t) {
    final s = <String>{};
    if (t.contains('park') || t.contains('hiking_area')) s.addAll(['calm', 'adventurous', 'reflective']);
    if (t.contains('museum') || t.contains('art_gallery') || t.contains('historical_landmark')) s.addAll(['curious', 'reflective']);
    if (t.contains('cafe') || t.contains('restaurant')) s.addAll(['social', 'curious']);
    if (t.contains('place_of_worship')) s.addAll(['calm', 'reflective']);
    if (t.contains('tourist_attraction')) s.addAll(['curious', 'adventurous']);
    return s.toList();
  }
}

class GoogleReview {
  final String author;
  final int rating;
  final String text;
  final String when;
  GoogleReview(this.author, this.rating, this.text, this.when);
}

/// Loads Google's written reviews live (max 5 per place). Do not store them in your database.
class GoogleReviews {
  static Future<List<GoogleReview>> fetch(String placeId) async {
    final res = await http.get(
      Uri.parse('https://places.googleapis.com/v1/places/$placeId'),
      headers: {'X-Goog-Api-Key': googleApiKey, 'X-Goog-FieldMask': 'reviews'},
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw AppException('Could not load Google reviews (${res.statusCode}).');
    final list = (jsonDecode(res.body)['reviews'] as List?) ?? [];
    return list.map((r) {
      final m = r as Map<String, dynamic>;
      return GoogleReview(
        (m['authorAttribution']?['displayName'] ?? 'A Google user') as String,
        (m['rating'] as num?)?.toInt() ?? 0,
        (m['text']?['text'] ?? '') as String,
        (m['relativePublishTimeDescription'] ?? '') as String,
      );
    }).toList();
  }
}
