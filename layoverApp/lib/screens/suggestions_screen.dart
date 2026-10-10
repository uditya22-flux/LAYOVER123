import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../config.dart';
import '../models.dart';
import '../services/google_places.dart';
import '../services/osm_places.dart';
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
  String? note;
  bool usedGoogle = false;
  bool usedOsm = false;

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
      note = null;
      usedGoogle = false;
      if (useGoogle) {
        try {
          all.addAll(await GooglePlaces.nearby(pos.latitude, pos.longitude, widget.maxKm * 1000));
          usedGoogle = true;
        } catch (_) {
          note = 'Google places are unavailable right now. Showing saved spots only.';
        }
      }
      usedOsm = false;
      try {
        all.addAll(await OsmPlaces.nearby(pos.latitude, pos.longitude, widget.maxKm * 1000));
        usedOsm = true;
      } catch (_) {
        note ??= 'Could not load nearby spots from OpenStreetMap. Showing saved spots only.';
      }
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
          title: 'Nothing within ${fmtDist(widget.maxKm)}',
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
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Spots within ${fmtDist(widget.maxKm)}', style: hand(28)),
              if (note != null) Text(note!, style: const TextStyle(fontSize: 13.5)),
              if (usedGoogle) const Text('Some place data from Google Maps Platform', style: TextStyle(fontSize: 12.5)),
              if (usedOsm) const Text('Place data from OpenStreetMap contributors', style: TextStyle(fontSize: 12.5)),
            ]);
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
          Text(fmtDist(place.distanceKm), style: const TextStyle(fontWeight: FontWeight.w800, color: C.ocean)),
        ]),
        const SizedBox(height: 6),
        if (place.legacyRating > 0)
          Row(children: [
            StarRow(place.legacyRating.round().clamp(0, 5), size: 18),
            const SizedBox(width: 8),
            Text('${place.legacyRating.toStringAsFixed(1)} legacy rating', style: const TextStyle(fontSize: 13.5)),
          ])
        else
          const TagPill('Hidden spot - not rated yet', color: C.sage),
        if (place.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(place.description, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (place.score >= 2) const TagPill('Matches your mood', color: C.sage),
          if (place.isSample) const TagPill('Sample data', color: C.mist),
        ]),
        if (place.isGoogle)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton.icon(
              onPressed: () => _showGoogleReviews(context, place),
              icon: const Icon(Icons.reviews_outlined),
              label: const Text('What Google reviewers say'),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton(onPressed: onGo, child: const Text('Go here')),
      ]),
    );
  }
}

void _showGoogleReviews(BuildContext context, Place place) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: C.cream,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .7,
      maxChildSize: .95,
      builder: (ctx, scroll) => FutureBuilder<List<GoogleReview>>(
        future: GoogleReviews.fetch(place.id),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: C.ocean));
          }
          if (snap.hasError) {
            return StateMessage(icon: Icons.cloud_off_rounded, title: 'Could not load', body: snap.error.toString());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const StateMessage(icon: Icons.chat_bubble_outline_rounded, title: 'No written reviews', body: 'Google has no written reviews for this place.');
          }
          return ListView(controller: scroll, padding: const EdgeInsets.all(20), children: [
            Text(place.name, style: hand(30)),
            const Text('Reviews from Google Maps', style: TextStyle(fontSize: 12.5)),
            const SizedBox(height: 12),
            for (final r in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoftCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(r.author, style: const TextStyle(fontWeight: FontWeight.w800))),
                      StarRow(r.rating, size: 16),
                    ]),
                    if (r.when.isNotEmpty) Text(r.when, style: const TextStyle(fontSize: 12.5)),
                    if (r.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(r.text, style: const TextStyle(fontSize: 15, height: 1.4)),
                    ],
                  ]),
                ),
              ),
          ]);
        },
      ),
    ),
  );
}