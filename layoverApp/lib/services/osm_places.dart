import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class OsmPlaces {
  static Future<List<Place>> nearby(double lat, double lng, double radiusM) async {
    try {
      final r = radiusM.clamp(100.0, 25000.0).round();
      // Overpass QL query around user's location for amenities, tourism, leisure
      final query = '''
[out:json][timeout:8];
(
  node["tourism"~"viewpoint|attraction|museum|artwork"](around:$r,$lat,$lng);
  node["amenity"~"cafe|restaurant|place_of_worship"](around:$r,$lat,$lng);
  node["leisure"~"park|nature_reserve"](around:$r,$lat,$lng);
);
out body 25;
''';
      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final res = await http.post(url, body: {'data': query}).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      final elements = (data['elements'] as List?) ?? [];
      final places = <Place>[];
      for (final el in elements) {
        final tags = el['tags'] as Map<String, dynamic>?;
        if (tags == null) continue;
        final name = tags['name'] as String?;
        if (name == null || name.trim().isEmpty) continue;
        final eLat = (el['lat'] as num?)?.toDouble();
        final eLng = (el['lon'] as num?)?.toDouble();
        if (eLat == null || eLng == null) continue;

        final tourism = tags['tourism']?.toString() ?? '';
        final amenity = tags['amenity']?.toString() ?? '';
        final leisure = tags['leisure']?.toString() ?? '';

        final moodTags = <String>[];
        String energy = 'medium';
        if (leisure == 'park' || tourism == 'viewpoint') {
          moodTags.addAll(['calm', 'reflective', 'adventurous']);
          energy = 'medium';
        } else if (tourism == 'museum' || tourism == 'artwork') {
          moodTags.addAll(['curious', 'reflective']);
          energy = 'low';
        } else if (amenity == 'cafe' || amenity == 'restaurant') {
          moodTags.addAll(['social', 'curious']);
          energy = 'low';
        } else {
          moodTags.addAll(['calm', 'curious']);
        }

        final desc = tags['description'] ?? tags['cuisine'] ?? 'Local spot from OpenStreetMap';
        places.add(Place(
          id: 'osm-${el['id']}',
          name: name,
          description: desc.toString(),
          lat: eLat,
          lng: eLng,
          legacyRating: 1.5,
          moodTags: moodTags,
          energy: energy,
          isSample: false,
        ));
      }
      return places;
    } catch (_) {
      return [];
    }
  }
}

