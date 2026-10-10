import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../config.dart';
import '../models.dart';
import '../services/location_service.dart';
import '../theme.dart';
import 'review_screen.dart';

class NavigationScreen extends StatefulWidget {
  final Place place;
  final LatLng start;
  const NavigationScreen({super.key, required this.place, required this.start});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late LatLng me = widget.start;
  late final LatLng dest = LatLng(widget.place.lat, widget.place.lng);
  RouteInfo? route;
  bool routeFailed = false;
  StreamSubscription<Position>? sub;
  late double distM = Geolocator.distanceBetween(me.latitude, me.longitude, dest.latitude, dest.longitude);

  bool get arrived => kDemoUnlock || distM <= kArrivalRadiusM;

  @override
  void initState() {
    super.initState();
    LocationService.route(widget.start, dest).then((r) {
      if (!mounted) return;
      setState(() {
        route = r;
        routeFailed = r == null;
      });
    });
    sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((p) {
      if (!mounted) return;
      setState(() {
        me = LatLng(p.latitude, p.longitude);
        distM = Geolocator.distanceBetween(p.latitude, p.longitude, dest.latitude, dest.longitude);
      });
    }, onError: (_) {});
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  String get distanceText => distM >= 1000 ? '${(distM / 1000).toStringAsFixed(1)} km to go' : '${distM.round()} m to go';

  @override
  Widget build(BuildContext context) {
    final line = route?.points ?? [me, dest];
    return Scaffold(
      appBar: AppBar(title: Text(widget.place.name, style: hand(26))),
      body: Column(children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds(widget.start, dest),
                padding: const EdgeInsets.all(70),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.roveya',
              ),
              PolylineLayer(polylines: [
                Polyline(points: line, strokeWidth: 5, color: C.ocean, pattern: route == null ? StrokePattern.dashed(segments: const [10, 8]) : const StrokePattern.solid()),
              ]),
              MarkerLayer(markers: [
                Marker(
                  point: me,
                  width: 28,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      color: C.seaGlass,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
                Marker(
                  point: dest,
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on_rounded, color: C.peach, size: 48),
                ),
              ]),
              const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: BoxDecoration(
            color: C.cream,
            border: Border(top: BorderSide(color: C.ocean.withOpacity(.15))),
          ),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(distanceText, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.ocean)),
              const SizedBox(height: 2),
              Text(
                route != null
                    ? 'Route ${route!.km.toStringAsFixed(1)} km by road, about ${route!.minutes.round()} min'
                    : routeFailed
                        ? 'Road route unavailable, showing a straight line'
                        : 'Finding the route...',
                style: const TextStyle(fontSize: 14.5),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                icon: Icon(arrived ? Icons.check_circle_rounded : Icons.lock_outline_rounded),
                label: const Text('I Have Arrived / Check In'),
                onPressed: arrived
                    ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen(place: widget.place)))
                    : null,
              ),
              if (!arrived)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Unlocks within ${kArrivalRadiusM.round()} m of the spot.', style: const TextStyle(fontSize: 13.5)),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}
