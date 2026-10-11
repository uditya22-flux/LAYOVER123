import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isSupabaseConfigured) {
    try {
      await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  }
  runApp(const RoveyaApp());
}

class RoveyaApp extends StatelessWidget {
  const RoveyaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Roveya',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashScreen(),
      );
}
