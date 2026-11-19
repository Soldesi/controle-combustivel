import 'package:flutter/material.dart';

const kGreen = Color(0xFF2E7D32);
const kGreenDark = Color(0xFF1B5E20);
const kGreenLight = Color(0xFF66BB6A);
const kTeal = Color(0xFF00897B);
const kLime = Color(0xFF7CB342);
const kBackground = Color(0xFFF1F8F2);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kGreen,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: kGreen,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kGreen,
      foregroundColor: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: kGreenLight.withOpacity(0.35),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kGreen,
        minimumSize: const Size.fromHeight(50),
      ),
    ),
  );
}
