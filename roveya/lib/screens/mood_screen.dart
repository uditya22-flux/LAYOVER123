import 'package:flutter/material.dart';
import '../config.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'suggestions_screen.dart';

const _moods = [
  ('calm', 'Calm', 'I want somewhere quiet'),
  ('curious', 'Curious', 'Show me something odd'),
  ('adventurous', 'Adventurous', 'I am up for anything'),
  ('reflective', 'Reflective', 'I want space to think'),
  ('social', 'Social', 'Open to meeting locals'),
];

const _energies = [
  ('low', 'Low', 'Short and easy today'),
  ('medium', 'Medium', 'A bit of effort is fine'),
  ('high', 'High', 'Bring on the climb'),
];

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? mood;
  String? energy;
  double km = kDefaultRadiusKm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How are you today?')),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
            Text('How are you feeling right now?', style: hand(30)),
            const SizedBox(height: 10),
            for (final m in _moods)
              OptionTile(title: m.$2, subtitle: m.$3, selected: mood == m.$1, onTap: () => setState(() => mood = m.$1)),
            const SizedBox(height: 18),
            Text('And your energy level?', style: hand(30)),
            const SizedBox(height: 10),
            for (final e in _energies)
              OptionTile(title: e.$2, subtitle: e.$3, selected: energy == e.$1, onTap: () => setState(() => energy = e.$1)),
            const SizedBox(height: 18),
            Text('How far will you go?', style: hand(30)),
            Row(children: [
              Expanded(
                child: Slider(
                  value: km,
                  min: kMinRadiusKm,
                  max: kMaxRadiusKm,
                  divisions: (kMaxRadiusKm - kMinRadiusKm).round(),
                  activeColor: C.ocean,
                  label: '${km.round()} km',
                  onChanged: (v) => setState(() => km = v),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text('${km.round()} km', textAlign: TextAlign.end, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.ocean)),
              ),
            ]),
          ]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: FilledButton(
              onPressed: (mood == null || energy == null)
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SuggestionsScreen(mood: mood!, energy: energy!, maxKm: km))),
              child: const Text('Show me places'),
            ),
          ),
        ),
      ]),
    );
  }
}
