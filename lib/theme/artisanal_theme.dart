import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtisanalTheme {
  // Color Palette
  static const Color background = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFDFDFD);
  static const Color primary = Color(0xFF804E2E);
  static const Color primaryContainer = Color(0xFF9C6644);
  static const Color secondary = Color(0xFF6C5B51);
  static const Color outline = Color(0xFF84746B);
  static const Color onSurface = Color(0xFF2D241E);
  static const Color ink = Color(0xFF4A3B32);
  static const Color redInk = Color(0xFF8B3A3A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: background,
        primary: primary,
        secondary: secondary,
        outline: outline,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        // Headlines: Noto Serif
        displayLarge: GoogleFonts.notoSerif(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: onSurface,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.notoSerif(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.notoSerif(
          fontSize: 24,
          fontStyle: FontStyle.italic,
          color: primary,
        ),
        // Body: Manrope
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Handwritten helper methods
  static TextStyle hand({double fontSize = 24, Color color = primary, double? height}) {
    return GoogleFonts.caveat(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      height: height,
    );
  }

  static TextStyle note({double fontSize = 22, Color color = ink}) {
    return GoogleFonts.reenieBeanie(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle pen({double fontSize = 20, Color color = ink}) {
    return GoogleFonts.nanumPenScript(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}
