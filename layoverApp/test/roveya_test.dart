import 'package:flutter_test/flutter_test.dart';
import 'package:roveya/models.dart';
import 'package:roveya/services/backend.dart';
import 'package:roveya/services/location_service.dart';

void main() {
  group('Roveya Models', () {
    test('featureTags contains all required tags', () {
      expect(featureTags, containsAll([
        'Views',
        'Food',
        'Quiet',
        'Culture',
        'Nature',
        'Craft',
        'People',
        'Other',
      ]));
    });

    test('Place model fromMap and copyWith', () {
      final map = {
        'id': 'p1',
        'name': 'Test Diner',
        'description': '1 star reviews hate the grease',
        'lat': 12.0,
        'lng': 76.0,
        'legacy_rating': 1.2,
        'mood_tags': ['calm', 'reflective'],
        'energy': 'low',
        'is_sample': true,
      };

      final place = Place.fromMap(map);
      expect(place.id, 'p1');
      expect(place.name, 'Test Diner');
      expect(place.legacyRating, 1.2);
      expect(place.moodTags, ['calm', 'reflective']);
      expect(place.energy, 'low');
      expect(place.isSample, true);

      final updated = place.copyWith(lat: 13.5, lng: 77.5);
      expect(updated.lat, 13.5);
      expect(updated.lng, 77.5);
      expect(updated.name, 'Test Diner');
    });

    test('Review model fromMap', () {
      final map = {
        'id': 'r1',
        'place_id': 'p1',
        'places': {'name': 'Test Diner'},
        'video_url': 'https://example.com/video.mp4',
        'rating': 5,
        'feature_tag': 'Food',
        'highlight': 'Their apple pie is 5 stars',
        'created_at': '2026-10-10T12:00:00Z',
      };

      final review = Review.fromMap(map);
      expect(review.id, 'r1');
      expect(review.placeName, 'Test Diner');
      expect(review.rating, 5);
      expect(review.featureTag, 'Food');
      expect(review.highlight, 'Their apple pie is 5 stars');
    });
  });

  group('Location & Scoring', () {
    test('distanceKm calculation', () {
      // Distance between (0, 0) and (0, 1) degrees at equator is ~111 km
      final dist = LocationService.distanceKm(0, 0, 0, 1);
      expect(dist, greaterThan(110));
      expect(dist, lessThan(112));
    });

    test('Mood and energy scoring logic', () {
      final place = Place(
        id: 'p1',
        name: 'Hilltop Spot',
        description: 'Rocky path',
        lat: 10,
        lng: 70,
        legacyRating: 1.0,
        moodTags: ['adventurous', 'curious'],
        energy: 'high',
        isSample: true,
      );

      final scoreMatchAll = (place.moodTags.contains('adventurous') ? 2 : 0) +
          (place.energy == 'high' ? 1 : 0);
      expect(scoreMatchAll, 3);

      final scoreMatchMoodOnly = (place.moodTags.contains('curious') ? 2 : 0) +
          (place.energy == 'low' ? 1 : 0);
      expect(scoreMatchMoodOnly, 2);

      final scoreMatchNone = (place.moodTags.contains('calm') ? 2 : 0) +
          (place.energy == 'low' ? 1 : 0);
      expect(scoreMatchNone, 0);
    });

    test('Multiple mood scoring logic', () {
      final place = Place(
        id: 'p1',
        name: 'Hilltop Spot',
        description: 'Rocky path',
        lat: 10,
        lng: 70,
        legacyRating: 1.0,
        moodTags: ['adventurous', 'curious', 'reflective'],
        energy: 'high',
        isSample: true,
      );

      final selectedMoods = ['adventurous', 'curious'];
      final matchCount = place.moodTags.where((m) => selectedMoods.contains(m)).length;
      final score = (matchCount * 2) + (place.energy == 'high' ? 1 : 0);
      expect(score, 5); // 2*2 + 1 = 5
    });
  });

  group('Backend Fallbacks', () {
    test('fetchPlaces returns places and anchors near user', () async {
      final places = await Backend.fetchPlaces(userLat: 13.0, userLng: 77.0);
      expect(places.isNotEmpty, true);
      // All places should be within reasonable distance from (13.0, 77.0)
      for (final p in places) {
        final d = LocationService.distanceKm(13.0, 77.0, p.lat, p.lng);
        expect(d, lessThan(20.0));
      }
    });

    test('TinkerHub Calicut Gate exists and is within 500m and 400m for walking demo', () async {
      final places = await Backend.fetchPlaces(userLat: 11.2748, userLng: 75.8202);
      final gate = places.firstWhere((p) => p.name.contains('TinkerHub') || p.name.contains('TinkerSpace'));
      final distKm = LocationService.distanceKm(11.2748, 75.8202, gate.lat, gate.lng);
      expect(distKm, lessThan(0.50)); // under 500m
      expect(distKm, lessThan(0.40)); // under 400m
    });

    test('fetchReviews returns reviews and filters by featureTag', () async {
      final all = await Backend.fetchReviews();
      expect(all.isNotEmpty, true);

      final foodOnly = await Backend.fetchReviews(featureTag: 'Food');
      expect(foodOnly.every((r) => r.featureTag.toLowerCase() == 'food'), true);

      final viewsOnly = await Backend.fetchReviews(featureTag: 'Views');
      expect(viewsOnly.every((r) => r.featureTag.toLowerCase() == 'views'), true);
    });

    test('insertReview immediately adds to reviews feed', () async {
      await Backend.insertReview(
        placeId: 'sample-test',
        placeName: 'Test Secret Bakery',
        videoUrl: 'https://example.com/test.mp4',
        featureTag: 'Craft',
        highlight: 'Fresh sourdough baked by grandma',
      );

      final reviews = await Backend.fetchReviews(featureTag: 'Craft');
      expect(reviews.any((r) => r.placeName == 'Test Secret Bakery'), true);
    });
  });
}

