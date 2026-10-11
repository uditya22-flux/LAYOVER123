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
  final bool isGoogle;
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
    this.isGoogle = false,
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

  Place copyWith({
    String? id,
    String? name,
    String? description,
    double? lat,
    double? lng,
    double? legacyRating,
    List<String>? moodTags,
    String? energy,
    bool? isSample,
    bool? isGoogle,
  }) =>
      Place(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        legacyRating: legacyRating ?? this.legacyRating,
        moodTags: moodTags ?? this.moodTags,
        energy: energy ?? this.energy,
        isSample: isSample ?? this.isSample,
        isGoogle: isGoogle ?? this.isGoogle,
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

  factory Review.fromMap(Map<String, dynamic> m) {
    String pName = 'Unknown place';
    if (m['places'] is Map && m['places']['name'] != null) {
      pName = m['places']['name'].toString();
    } else if (m['place_name'] != null) {
      pName = m['place_name'].toString();
    }
    return Review(
      id: m['id'].toString(),
      placeId: m['place_id']?.toString() ?? '',
      placeName: pName,
      videoUrl: m['video_url']?.toString() ?? '',
      rating: (m['rating'] as num?)?.toInt() ?? 5,
      featureTag: (m['feature_tag'] ?? 'Other').toString(),
      highlight: (m['highlight'] ?? '').toString(),
      createdAt: m['created_at'] != null
          ? DateTime.parse(m['created_at'].toString()).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'place_id': placeId,
        'place_name': placeName,
        'video_url': videoUrl,
        'rating': rating,
        'feature_tag': featureTag,
        'highlight': highlight,
        'created_at': createdAt.toIso8601String(),
      };
}

class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}