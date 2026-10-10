import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'feed_screen.dart';
import 'mood_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: CoastPainter())),
              Positioned(
                left: 24,
                top: MediaQuery.of(context).padding.top + 16,
                child: Text('Roveya', style: hand(54)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Find your kind of places.', style: hand(34)),
              const SizedBox(height: 10),
              const Text(
                'Skip the crowded five-star spots. Visit a one-star place and find the one five-star thing hiding inside it.',
                style: TextStyle(fontSize: 16.5, height: 1.45),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Take a Challenge'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen())),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('Browse Reviews'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedScreen())),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
