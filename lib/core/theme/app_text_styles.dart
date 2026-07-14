import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // ═══════════════════════════════════════════════════════
  // FONT FAMILIES
  // ═══════════════════════════════════════════════════════
  static const String arabicFont = 'Amiri';
  static const String primaryFont = 'Poppins';

  // ═══════════════════════════════════════════════════════
  // ARABIC TEXT (For Al-Qur'an)
  // ═══════════════════════════════════════════════════════

  static TextStyle arabic({
    double size = 28,
    Color? color,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontFamily: arabicFont,
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: 2.2,
      letterSpacing: 0.5,
    );
  }

  static TextStyle arabicLarge({
    double size = 32,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: arabicFont,
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w700,
      height: 2.4,
    );
  }

  // ═══════════════════════════════════════════════════════
  // HEADINGS
  // ═══════════════════════════════════════════════════════

  static TextStyle h1({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle h2({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle h3({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle h4({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.4,
    );
  }

  // ═══════════════════════════════════════════════════════
  // BODY TEXT
  // ═══════════════════════════════════════════════════════

  static TextStyle bodyLarge({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium({Color? color, double? height, FontWeight? weight}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: weight ?? FontWeight.w400,
      color: color,
      height: height ?? 1.5,
    );
  }

  static TextStyle bodySmall({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  // ═══════════════════════════════════════════════════════
  // BUTTONS
  // ═══════════════════════════════════════════════════════

  static TextStyle buttonLarge({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.5,
    );
  }

  static TextStyle buttonMedium({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.3,
    );
  }

  // ═══════════════════════════════════════════════════════
  // CAPTION & LABELS
  // ═══════════════════════════════════════════════════════

  static TextStyle caption({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle label({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 0.5,
    );
  }

  // ═══════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════

  // Surah number in circle
  static TextStyle surahNumber({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  // Prayer time display
  static TextStyle prayerTime({Color? color}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.0,
    );
  }

  // Tasbih counter
  static TextStyle tasbihCounter({Color? color, double size = 48}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }
}
