import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const seaGlass = Color(0xFF3F8490);
  static const ocean = Color(0xFF205B68);
  static const mist = Color(0xFFDCEBF0);
  static const cream = Color(0xFFFFF8ED);
  static const peach = Color(0xFFF3A184);
  static const butter = Color(0xFFF6DDA5);
  static const sage = Color(0xFF9AAE8B);
  static const ink = Color(0xFF25383A);
}

TextStyle hand(double size, {Color color = C.ocean}) =>
    GoogleFonts.caveat(fontSize: size, fontWeight: FontWeight.w700, color: color);

ThemeData buildTheme() {
  final base = GoogleFonts.nunitoTextTheme().apply(bodyColor: C.ink, displayColor: C.ink);
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: C.cream,
    colorScheme: ColorScheme.fromSeed(seedColor: C.seaGlass, primary: C.ocean, surface: C.cream),
    textTheme: base,
    appBarTheme: AppBarTheme(
      backgroundColor: C.cream,
      foregroundColor: C.ocean,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: hand(30),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.ocean,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.ocean,
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: C.ocean, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: C.ocean.withOpacity(.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: C.ocean.withOpacity(.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.ocean, width: 1.6),
      ),
    ),
  );
}
