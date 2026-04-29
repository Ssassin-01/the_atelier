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
  static const Color redInk = Color(0xFFB22222); // More vivid "Firebrick" red for better clarity
  static const Color greenInk = Color(0xFF2E7D32); // Deep forest green for positive entries

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
        // Headlines: Gowun Batang (Elegant Korean/English Serif)
        displayLarge: GoogleFonts.gowunBatang(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: onSurface,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.gowunBatang(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.gowunBatang(
          fontSize: 24,
          fontStyle: FontStyle.italic,
          color: primary,
        ),
        // Body: Gowun Dodum (Clean & Modern)
        bodyLarge: GoogleFonts.gowunDodum(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.gowunDodum(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        labelLarge: GoogleFonts.gowunDodum(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Handwritten helper methods supporting both Ko/En
  static TextStyle hand({
    double fontSize = 24,
    Color color = primary,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    // Nanum Pen Script is a reliable artisanal choice for both languages
    return GoogleFonts.nanumPenScript(
      fontSize: fontSize + 2, // It tends to run a bit small
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  static TextStyle note({
    double fontSize = 22,
    Color color = ink,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.nanumPenScript(
      fontSize: fontSize + 2,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle pen({double fontSize = 20, Color color = ink}) {
    return GoogleFonts.nanumPenScript(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // Receipt helper: Monospace for that "thermal printer" look
  static TextStyle receipt({
    double fontSize = 14,
    Color color = ink,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.nanumGothicCoding(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}
