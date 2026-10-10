import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models.dart';

class RouteInfo {
  final List<LatLng> points;
  final double km;
  final double minutes;
  RouteInfo(this.points, this.km, this.minutes);
}

class LocationService {
  static Future<Position> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw AppException('Location is switched off. Turn it on to find spots near you.');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) {
      throw AppException('We need location permission to find places near you.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw AppException('Location permission is blocked. Enable it in your phone settings.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  static double distanceKm(double aLat, double aLng, double bLat, double bLng) =>
      Geolocator.distanceBetween(aLat, aLng, bLat, bLng) / 1000;

  /// Public OSRM demo server (road route). Returns null on failure -> UI falls back to a straight line.
  static Future<RouteInfo?> route(LatLng from, LatLng to) async {
    try {
      final url = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson');
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final r = (jsonDecode(res.body)['routes'] as List).first;
      final coords = (r['geometry']['coordinates'] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      return RouteInfo(coords, (r['distance'] as num) / 1000, (r['duration'] as num) / 60);
    } catch (_) {
      return null;
    }
  }
}
