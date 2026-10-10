import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models.dart';
import '../services/backend.dart';
import '../services/location_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'navigation_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  final String mood;
  final String energy;
  final double maxKm;
  const SuggestionsScreen({super.key, required this.mood, required this.energy, required this.maxKm});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  bool loading = true;
  String? error;
  List<Place> places = [];
  LatLng? me;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final pos = await LocationService.current();
      final all = await Backend.fetchPlaces();
      final nearby = <Place>[];
      for (final p in all) {
        p.distanceKm = LocationService.distanceKm(pos.latitude, pos.longitude, p.lat, p.lng);
        if (p.distanceKm > widget.maxKm) continue;
        p.score = (p.moodTags.contains(widget.mood) ? 2 : 0) + (p.energy == widget.energy ? 1 : 0);
        nearby.add(p);
      }
      nearby.sort((a, b) {
        final s = b.score.compareTo(a.score);
        return s != 0 ? s : a.distanceKm.compareTo(b.distanceKm);
      });
      if (!mounted) return;
      setState(() {
        me = LatLng(pos.latitude, pos.longitude);
        places = nearby;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator(color: C.ocean));
    } else if (error != null) {
      body = StateMessage(
          icon: Icons.location_off_rounded, title: 'Hmm, something is off', body: error!, actionLabel: 'Try again', onAction: _load);
    } else if (places.isEmpty) {
      body = StateMessage(
          icon: Icons.explore_off_rounded,
          title: 'Nothing within ${widget.maxKm.round()} km',
          body: 'No one-star spots found in that range. Go back and try a larger distance.',
          actionLabel: 'Refresh',
          onAction: _load);
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: places.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          if (i == 0) {
            return Text('One-star spots within ${widget.maxKm.round()} km', style: hand(28));
          }
          return _PlaceCard(place: places[i - 1], onGo: () => _go(places[i - 1]));
        },
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('Your spots')), body: body);
  }

  void _go(Place p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NavigationScreen(place: p, start: me!)));
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onGo;
  const _PlaceCard({required this.place, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(place.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
          Text('${place.distanceKm.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.w800, color: C.ocean)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          StarRow(place.legacyRating.round().clamp(0, 5), size: 18),
          const SizedBox(width: 8),
          Text('${place.legacyRating.toStringAsFixed(1)} legacy rating', style: const TextStyle(fontSize: 13.5)),
        ]),
        if (place.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(place.description, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (place.score >= 2) const TagPill('Matches your mood', color: C.sage),
          if (place.isSample) TagPill('Sample data', color: C.mist),
        ]),
        const SizedBox(height: 12),
        FilledButton(onPressed: onGo, child: const Text('Go here')),
      ]),
    );
  }
}
