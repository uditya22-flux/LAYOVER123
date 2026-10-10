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

class _NavigationScreenState extends State<NavigationScreen> with SingleTickerProviderStateMixin {
  final _map = MapController();
  late LatLng me = widget.start;
  late final LatLng dest = LatLng(widget.place.lat, widget.place.lng);
  late LatLng _routeFrom = widget.start;
  RouteInfo? route;
  bool routeFailed = false;
  bool _rerouting = false;
  bool _mapReady = false;
  bool following = true;

  // Smooth position & rotation animation
  late AnimationController _anim;
  LatLng _animStartPos = const LatLng(0, 0);
  LatLng _animTargetPos = const LatLng(0, 0);
  double _animStartHeading = 0;
  double _animTargetHeading = 0;
  double _displayHeading = 0;

  StreamSubscription<Position>? sub;
  late double distM = Geolocator.distanceBetween(me.latitude, me.longitude, dest.latitude, dest.longitude);

  Timer? _simTimer;
  int _simStep = 0;

  bool get arrived => kDemoUnlock || distM <= kArrivalRadiusM;

  @override
  void initState() {
    super.initState();
    _animStartPos = widget.start;
    _animTargetPos = widget.start;

    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))
      ..addListener(() {
        final t = Curves.easeInOutCubic.transform(_anim.value);
        final lat = _animStartPos.latitude + (_animTargetPos.latitude - _animStartPos.latitude) * t;
        final lng = _animStartPos.longitude + (_animTargetPos.longitude - _animStartPos.longitude) * t;
        me = LatLng(lat, lng);

        // Shortest arc angle interpolation
        final diff = ((_animTargetHeading - _animStartHeading + 540) % 360) - 180;
        _displayHeading = (_animStartHeading + diff * t) % 360;

        if (following && _mapReady) {
          _map.move(me, _map.camera.zoom);
        }
        setState(() {});
      });

    _fetchRoute();

    sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0, // Continuous stream without jumpy deadbands
      ),
    ).listen(_onPosition, onError: (_) {});
  }

  void _animateTo(LatLng target, double targetHeading, {Duration duration = const Duration(milliseconds: 750)}) {
    _anim.stop();
    _animStartPos = me;
    _animTargetPos = target;
    _animStartHeading = _displayHeading;
    _animTargetHeading = targetHeading;
    _anim.duration = duration;
    _anim.forward(from: 0.0);
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
    if (_simTimer != null) return; // Prioritize manual simulation if running
    final here = LatLng(p.latitude, p.longitude);

    double nextHeading = _displayHeading;
    if (p.heading > 0) {
      nextHeading = p.heading;
    } else {
      final moved = Geolocator.distanceBetween(me.latitude, me.longitude, here.latitude, here.longitude);
      if (moved >= 1.0) {
        nextHeading = Geolocator.bearingBetween(me.latitude, me.longitude, here.latitude, here.longitude);
      }
    }

    distM = Geolocator.distanceBetween(p.latitude, p.longitude, dest.latitude, dest.longitude);
    _animateTo(here, nextHeading, duration: const Duration(milliseconds: 750));

    // Refresh route when user has moved 120m away from where route was generated
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
    _simTimer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_simStep < pts.length) {
        final targetPt = pts[_simStep];
        final nextPt = (_simStep + 1 < pts.length) ? pts[_simStep + 1] : dest;
        final turnAngle = Geolocator.bearingBetween(targetPt.latitude, targetPt.longitude, nextPt.latitude, nextPt.longitude);

        distM = Geolocator.distanceBetween(targetPt.latitude, targetPt.longitude, dest.latitude, dest.longitude);
        _animateTo(targetPt, turnAngle, duration: const Duration(milliseconds: 750));

        _simStep++;
      } else {
        t.cancel();
        _simTimer = null;
        distM = 0;
        _animateTo(dest, _displayHeading, duration: const Duration(milliseconds: 500));
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _anim.dispose();
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
                    width: 46,
                    height: 46,
                    child: Container(
                      decoration: BoxDecoration(
                        color: C.seaGlass,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: C.ink.withValues(alpha: .3), blurRadius: 6)],
                      ),
                      child: Transform.rotate(
                        angle: _displayHeading * math.pi / 180,
                        child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 26),
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