import 'dart:async';
import 'dart:math' as math;
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
  final _map = MapController();
  late LatLng me = widget.start;
  late final LatLng dest = LatLng(widget.place.lat, widget.place.lng);
  late LatLng _routeFrom = widget.start;
  RouteInfo? route;
  bool routeFailed = false;
  bool _rerouting = false;
  bool _mapReady = false;
  bool following = true;
  double heading = 0;
  StreamSubscription<Position>? sub;
  late double distM = Geolocator.distanceBetween(me.latitude, me.longitude, dest.latitude, dest.longitude);

  Timer? _simTimer;
  int _simStep = 0;

  bool get arrived => kDemoUnlock || distM <= kArrivalRadiusM;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).listen(_onPosition, onError: (_) {});
  }

  Future<void> _fetchRoute() async {
    if (_rerouting) return;
    _rerouting = true;
    final from = me;
    final r = await LocationService.route(from, dest);
    _rerouting = false;
    if (!mounted) return;
    setState(() {
      if (r != null) {
        route = r;
        routeFailed = false;
        _routeFrom = from;
      } else if (route == null) {
        routeFailed = true;
      }
    });
  }

  void _onPosition(Position p) {
    if (!mounted) return;
    if (_simTimer != null) return; // Let manual simulation run without GPS override
    final here = LatLng(p.latitude, p.longitude);
    double newHeading = heading;
    if (p.heading > 0) {
      newHeading = p.heading;
    } else {
      final moved = Geolocator.distanceBetween(me.latitude, me.longitude, here.latitude, here.longitude);
      if (moved >= 1.5) {
        newHeading = Geolocator.bearingBetween(me.latitude, me.longitude, here.latitude, here.longitude);
      }
    }

    setState(() {
      me = here;
      heading = newHeading;
      distM = Geolocator.distanceBetween(p.latitude, p.longitude, dest.latitude, dest.longitude);
    });

    if (following && _mapReady) {
      _map.move(here, _map.camera.zoom);
    }

    // Refresh route when user has moved 120m
    final moved = Geolocator.distanceBetween(_routeFrom.latitude, _routeFrom.longitude, here.latitude, here.longitude);
    if (moved > 120 && distM > kArrivalRadiusM) _fetchRoute();
  }

  void _toggleSimulateWalk() {
    if (_simTimer != null) {
      _simTimer?.cancel();
      _simTimer = null;
      setState(() {});
      return;
    }

    final pts = route?.points;
    if (pts == null || pts.isEmpty) return;

    _simStep = 0;
    _simTimer = Timer.periodic(const Duration(milliseconds: 600), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_simStep < pts.length) {
        final targetPt = pts[_simStep];
        final nextPt = (_simStep + 1 < pts.length) ? pts[_simStep + 1] : dest;
        final turnAngle = Geolocator.bearingBetween(targetPt.latitude, targetPt.longitude, nextPt.latitude, nextPt.longitude);

        setState(() {
          me = targetPt;
          heading = turnAngle;
          distM = Geolocator.distanceBetween(targetPt.latitude, targetPt.longitude, dest.latitude, dest.longitude);
        });

        if (following && _mapReady) {
          _map.move(targetPt, _map.camera.zoom);
        }
        _simStep++;
      } else {
        t.cancel();
        _simTimer = null;
        setState(() {
          me = dest;
          distM = 0;
        });
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    sub?.cancel();
    _map.dispose();
    super.dispose();
  }

  void _recenter() {
    setState(() => following = true);
    if (_mapReady) _map.move(me, 17);
  }

  void _overview() {
    setState(() => following = false);
    final pts = [me, dest, ...(route?.points ?? const <LatLng>[])];
    _map.fitCamera(CameraFit.bounds(bounds: LatLngBounds.fromPoints(pts), padding: const EdgeInsets.all(70)));
  }

  String get distanceText => distM >= 1000 ? '${(distM / 1000).toStringAsFixed(1)} km to go' : '${distM.round()} m to go';

  @override
  Widget build(BuildContext context) {
    final line = route?.points ?? [me, dest];
    return Scaffold(
      appBar: AppBar(title: Text(widget.place.name, style: hand(26))),
      body: Column(children: [
        Expanded(
          child: Stack(children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: widget.start,
                initialZoom: 17,
                onMapReady: () {
                  _mapReady = true;
                  if (following) _map.move(me, 17);
                },
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture && following) setState(() => following = false);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.roveya',
                ),
                PolylineLayer(polylines: [
                  Polyline(
                    points: line,
                    strokeWidth: 6,
                    color: C.ocean,
                    pattern: route == null ? StrokePattern.dashed(segments: const [10, 8]) : const StrokePattern.solid(),
                  ),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: dest,
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on_rounded, color: C.peach, size: 48),
                  ),
                  Marker(
                    point: me,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: C.seaGlass,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: C.ink.withValues(alpha: .3), blurRadius: 6)],
                      ),
                      child: Transform.rotate(
                        angle: heading * math.pi / 180,
                        child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ]),
                const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
              ],
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Column(children: [
                FloatingActionButton.small(
                  heroTag: 'recenter',
                  backgroundColor: following ? C.ocean : Colors.white,
                  foregroundColor: following ? Colors.white : C.ocean,
                  tooltip: 'Follow me',
                  onPressed: _recenter,
                  child: const Icon(Icons.my_location_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'overview',
                  backgroundColor: Colors.white,
                  foregroundColor: C.ocean,
                  tooltip: 'Show whole route',
                  onPressed: _overview,
                  child: const Icon(Icons.route_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'simulate',
                  backgroundColor: _simTimer != null ? C.peach : Colors.white,
                  foregroundColor: _simTimer != null ? Colors.white : C.ocean,
                  tooltip: _simTimer != null ? 'Stop walking' : 'Simulate walk',
                  onPressed: _toggleSimulateWalk,
                  child: Icon(_simTimer != null ? Icons.pause_rounded : Icons.directions_walk_rounded),
                ),
              ]),
            ),
          ]),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: BoxDecoration(
            color: C.cream,
            border: Border(top: BorderSide(color: C.ocean.withValues(alpha: .15))),
          ),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(arrived ? 'You are here' : distanceText,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.ocean)),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Unlocks within ${kArrivalRadiusM.round()} m of the spot.', style: const TextStyle(fontSize: 13.5)),
                      ),
                      TextButton.icon(
                        icon: Icon(_simTimer != null ? Icons.pause : Icons.directions_walk, size: 16),
                        label: Text(_simTimer != null ? 'Stop walk' : 'Simulate walk', style: const TextStyle(fontSize: 13)),
                        onPressed: _toggleSimulateWalk,
                      ),
                    ],
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}