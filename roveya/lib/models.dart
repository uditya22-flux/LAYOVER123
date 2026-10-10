const featureTags = ['Views', 'Food', 'Quiet', 'Culture', 'Nature', 'Craft', 'People', 'Other'];

class Place {
  final String id;
  final String name;
  final String description;
  final double lat;
  final double lng;
  final double legacyRating;
  final List<String> moodTags;
  final String energy; // low | medium | high
  final bool isSample;
  double distanceKm = 0;
  int score = 0;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.legacyRating,
    required this.moodTags,
    required this.energy,
    required this.isSample,
  });

  factory Place.fromMap(Map<String, dynamic> m) => Place(
        id: m['id'].toString(),
        name: m['name'] as String,
        description: (m['description'] ?? '') as String,
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        legacyRating: (m['legacy_rating'] as num).toDouble(),
        moodTags: ((m['mood_tags'] ?? []) as List).map((e) => e.toString()).toList(),
        energy: (m['energy'] ?? 'medium') as String,
        isSample: (m['is_sample'] ?? false) as bool,
      );
}

class Review {
  final String id;
  final String placeId;
  final String placeName;
  final String videoUrl;
  final int rating;
  final String featureTag;
  final String highlight;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.videoUrl,
    required this.rating,
    required this.featureTag,
    required this.highlight,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> m) => Review(
        id: m['id'].toString(),
        placeId: m['place_id'].toString(),
        placeName: (m['places']?['name'] ?? 'Unknown place') as String,
        videoUrl: m['video_url'] as String,
        rating: (m['rating'] as num).toInt(),
        featureTag: (m['feature_tag'] ?? 'Other') as String,
        highlight: (m['highlight'] ?? '') as String,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );
}

class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}
