import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color voidBg = Color(0xFF0A0C11);
  static const Color pureBlack = Color(0xFF000000);
  static const Color cardBg = Color(0xFF0C0E14);
  static const Color cardWash = Color(0xFF12151E);
  static const Color cardHover = Color(0xFF181B26);

  // Aliases for convenience
  static const Color voidBlack = voidBg;
  static const Color wash = cardWash;
  static const Color cardSurface = cardBg;
  static const Color purple = purplePrimary;
  static const Color ash = textAsh;
  static const Color ashDim = textAshDim;

  // Accents
  static const Color purplePrimary = Color(0xFF7C3AED); // Purple 600
  static const Color purpleLight = Color(0xFFA78BFA);   // Purple 400
  static const Color purpleDark = Color(0xFF5B21B6);    // Purple 800
  static const Color discordColor = Color(0xFF5865F2);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color amberGold = Color(0xFFF59E0B);
  static const Color redError = Color(0xFFEF4444);

  // Neutrals
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textAsh = Color(0xFFA1A1AA);
  static const Color textAshDim = Color(0xFF71717A);
  static const Color hairline = Color(0x1FFFFFFF);        // ~12% white
  static const Color hairlineStrong = Color(0x2EFFFFFF);  // ~18% white

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBg,
      primaryColor: purplePrimary,
      colorScheme: const ColorScheme.dark(
        primary: purplePrimary,
        secondary: purpleLight,
        surface: cardBg,
        error: redError,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: voidBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: pureBlack,
        selectedItemColor: textWhite,
        unselectedItemColor: textAshDim,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      dividerColor: hairline,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textWhite, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textWhite),
        bodyMedium: TextStyle(color: textAsh),
      ),
    );
  }
}
