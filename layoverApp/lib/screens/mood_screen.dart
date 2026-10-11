import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// label, value, isKm
const _quick = [
  ('400 m', '400', false),
  ('500 m', '500', false),
  ('1 km', '1', true),
  ('3 km', '3', true),
  ('5 km', '5', true),
  ('10 km', '10', true),
  ('25 km', '25', true),
];

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final Set<String> moods = {};
  String? energy;
  final _dist = TextEditingController(text: '500');
  bool inKm = false;

  @override
  void dispose() {
    _dist.dispose();
    super.dispose();
  }

  double? get km {
    final v = double.tryParse(_dist.text.trim());
    if (v == null || v <= 0) return null;
    return inKm ? v : v / 1000;
  }

  String? get distError {
    if (_dist.text.trim().isEmpty) return 'Enter a distance';
    final k = km;
    if (k == null || k <= 0) return 'Enter a distance greater than 0';
    return null;
  }

  bool get ready => moods.isNotEmpty && energy != null && distError == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How are you today?')),
      body: Column(children: [
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text('How are you feeling right now?', style: hand(30)),
              Text('Select one or more moods that fit your vibe',
                  style: TextStyle(fontSize: 14.5, color: C.ink.withValues(alpha: .7))),
              const SizedBox(height: 10),
              for (final m in _moods)
                OptionTile(
                  title: m.$2,
                  subtitle: m.$3,
                  selected: moods.contains(m.$1),
                  onTap: () {
                    setState(() {
                      if (moods.contains(m.$1)) {
                        moods.remove(m.$1);
                      } else {
                        moods.add(m.$1);
                      }
                    });
                  },
                ),
              const SizedBox(height: 18),
              Text('And your energy level?', style: hand(30)),
              const SizedBox(height: 10),
              for (final e in _energies)
                OptionTile(
                  title: e.$2,
                  subtitle: e.$3,
                  selected: energy == e.$1,
                  onTap: () => setState(() => energy = e.$1),
                ),
              const SizedBox(height: 18),
              Text('How far can you travel?', style: hand(30)),
              Text('Set any distance you want (no limits)',
                  style: TextStyle(fontSize: 14.5, color: C.ink.withValues(alpha: .7))),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: TextField(
                    controller: _dist,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    decoration: InputDecoration(hintText: 'e.g. 500', errorText: distError),
                  ),
                ),
                const SizedBox(width: 10),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('m')),
                    ButtonSegment(value: true, label: Text('km')),
                  ],
                  selected: {inKm},
                  onSelectionChanged: (s) => setState(() => inKm = s.first),
                ),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final q in _quick)
                  ActionChip(
                    label: Text(q.$1),
                    onPressed: () => setState(() {
                      _dist.text = q.$2;
                      inKm = q.$3;
                    }),
                  ),
              ]),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: FilledButton(
              onPressed: !ready
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SuggestionsScreen(
                                moods: moods.toList(),
                                energy: energy!,
                                maxKm: km!,
                              ))),
              child: const Text('Show me places'),
            ),
          ),
        ),
      ]),
    );
  }
}