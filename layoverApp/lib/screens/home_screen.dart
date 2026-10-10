import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'feed_screen.dart';
import 'mood_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: CoastPainter())),
              Positioned(
                left: 20,
                right: 20,
                top: MediaQuery.of(context).padding.top + 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Roveya', style: hand(46)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: C.ocean.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.near_me_rounded, size: 14, color: C.peach),
                          SizedBox(width: 4),
                          Text(
                            'Kochi, India • 10 km',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.ink),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Gamified Level & Streak Card
              SoftCard(
                color: C.mist,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: C.ocean, size: 24),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Lv. 4 Discoverer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            Text('1,200 XP', style: TextStyle(fontSize: 12, color: C.ink)),
                          ],
                        ),
                      ],
                    ),
                    const TagPill('🔥 +5 Day Streak', color: C.butter),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Worst Rated. Best Stories.', style: hand(32)),
              const SizedBox(height: 6),
              const Text(
                'Skip crowded five-star spots. Visit a 1-star location, find its hidden redeeming quality, and flip the narrative.',
                style: TextStyle(fontSize: 15.5, height: 1.4),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Option A: Take the Challenge'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen())),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('Option B: Explore Discovered Gems'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedScreen())),
              ),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        selectedItemColor: C.ocean,
        unselectedItemColor: C.ink.withValues(alpha: 0.5),
        onTap: (index) {
          setState(() => _tabIndex = index);
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map / Missions'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'Saved'),
        ],
      ),
    );
  }
}
