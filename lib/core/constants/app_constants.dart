class AppConstants {
  AppConstants._();

  // ═══════════════════════════════════════════════════════
  // APP INFO
  // ═══════════════════════════════════════════════════════

  static const String appName = 'SakuMuslim';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Asisten Ibadah Muslim';

  // ═══════════════════════════════════════════════════════
  // QURAN CONSTANTS
  // ═══════════════════════════════════════════════════════

  static const int totalSurah = 114;
  static const int totalJuz = 30;
  static const int totalPage = 604;

  // ═══════════════════════════════════════════════════════
  // MASJIDIL HARAM COORDINATES
  // ═══════════════════════════════════════════════════════

  static const double masjidilHaramLatitude = 21.4225;
  static const double masjidilHaramLongitude = 39.8262;

  // ═══════════════════════════════════════════════════════
  // ZAKAT CONSTANTS
  // ═══════════════════════════════════════════════════════

  static const double zakatRate = 0.025; // 2.5%
  static const double nisabGoldGrams = 85.0;
  static const double nisabSilverGrams = 595.0;

  // ═══════════════════════════════════════════════════════
  // TASBIH CONSTANTS
  // ═══════════════════════════════════════════════════════

  static const int defaultTasbihTarget = 33;
  static const int maxTasbihTarget = 1000;

  // ═══════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════
  // SPACING
  // ═══════════════════════════════════════════════════════

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ═══════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
}
