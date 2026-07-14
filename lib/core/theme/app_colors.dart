import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════
  // PRIMARY PALETTE - BLUE GRADIENT
  // ═══════════════════════════════════════════════════════
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryLighter = Color(0xFF42A5F5);
  static const Color primarySurface = Color(0xFFBBDEFB);

  // ═══════════════════════════════════════════════════════
  // SECONDARY PALETTE - TEAL ACCENT
  // ═══════════════════════════════════════════════════════
  static const Color secondaryDark = Color(0xFF00695C);
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF26A69A);

  // ═══════════════════════════════════════════════════════
  // ACCENT - GOLD (Islamic accent)
  // ═══════════════════════════════════════════════════════
  static const Color accentGold = Color(0xFFC6A054);
  static const Color accentGoldLight = Color(0xFFE0C882);

  // ═══════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // ═══════════════════════════════════════════════════════
  // LIGHT THEME COLORS
  // ═══════════════════════════════════════════════════════
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A237E);
  static const Color textSecondaryLight = Color(0xFF546E7A);
  static const Color dividerLight = Color(0xFFE0E0E0);

  // ═══════════════════════════════════════════════════════
  // DARK THEME COLORS
  // ═══════════════════════════════════════════════════════
  static const Color backgroundDark = Color(0xFF0A1929);
  static const Color surfaceDark = Color(0xFF132F4C);
  static const Color cardDark = Color(0xFF1A3A5C);
  static const Color textPrimaryDark = Color(0xFFE3F2FD);
  static const Color textSecondaryDark = Color(0xFF90CAF9);
  static const Color dividerDark = Color(0xFF1E3A5F);

  // ═══════════════════════════════════════════════════════
  // THEME-AWARE HELPERS
  // ═══════════════════════════════════════════════════════

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color card(BuildContext context) =>
      isDark(context) ? cardDark : cardLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? surfaceDark : surfaceLight;

  static Color background(BuildContext context) =>
      isDark(context) ? backgroundDark : backgroundLight;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color divider(BuildContext context) =>
      isDark(context) ? dividerDark : dividerLight;

  // ═══════════════════════════════════════════════════════
  // SCREEN GRADIENTS (theme-aware)
  // ═══════════════════════════════════════════════════════

  /// Home tab gradient
  static LinearGradient homeGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1929), Color(0xFF0D47A1), Color(0xFF132F4C)],
        stops: [0.0, 0.3, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFFE3F2FD)],
      stops: [0.0, 0.2, 0.5, 1.0],
    );
  }

  /// Quran index gradient
  static LinearGradient quranGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1929), Color(0xFF0D47A1), Color(0xFF132F4C)],
        stops: [0.0, 0.35, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFFE3F2FD)],
      stops: [0.0, 0.35, 1.0],
    );
  }

  /// Surah detail gradient
  static LinearGradient detailGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A1929), Color(0xFF0D47A1), Color(0xFF132F4C)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryDark, primary, primaryLight],
    );
  }

  /// Prayer times gradient
  static LinearGradient prayerGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1929), Color(0xFF004D40), Color(0xFF132F4C)],
        stops: [0.0, 0.35, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF26A69A), Color(0xFFE0F2F1)],
      stops: [0.0, 0.2, 0.5, 1.0],
    );
  }

  /// Tasbih gradient
  static LinearGradient tasbihGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1929), Color(0xFF5D4037), Color(0xFF132F4C)],
        stops: [0.0, 0.35, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5D4037), Color(0xFF8D6E63), Color(0xFFC6A054), Color(0xFFFFF8E1)],
      stops: [0.0, 0.2, 0.5, 1.0],
    );
  }

  /// Zakat gradient
  static LinearGradient zakatGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1929), Color(0xFF283593), Color(0xFF132F4C)],
        stops: [0.0, 0.35, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF283593), Color(0xFF3949AB), Color(0xFF5C6BC0), Color(0xFFE8EAF6)],
      stops: [0.0, 0.2, 0.5, 1.0],
    );
  }

  /// Hadith gradient
  static LinearGradient hadithGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A1210), Color(0xFF3E2723), Color(0xFF2C1A14)],
        stops: [0.0, 0.35, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5D4037), Color(0xFF8D6E63), Color(0xFFA1887F), Color(0xFFEFEBE9)],
      stops: [0.0, 0.2, 0.5, 1.0],
    );
  }

  /// Kiblat gradient
  static LinearGradient kiblatGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1929), Color(0xFF0D47A1), Color(0xFF132F4C)],
        stops: [0.0, 0.35, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFFE3F2FD)],
      stops: [0.0, 0.35, 1.0],
    );
  }

  /// Settings gradient
  static LinearGradient settingsGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1929), Color(0xFF132F4C), Color(0xFF1A3A5C)],
        stops: [0.0, 0.3, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF37474F), Color(0xFF546E7A), Color(0xFF78909C), Color(0xFFECEFF1)],
      stops: [0.0, 0.15, 0.4, 1.0],
    );
  }

  /// Content area background (bottom section of screens)
  static Color contentBackground(BuildContext context) =>
      isDark(context) ? surfaceDark : backgroundLight;

  /// Card border color
  static Color cardBorder(BuildContext context) =>
      isDark(context) ? dividerDark : const Color(0xFFE3F2FD);

  /// Static gradients (for const widgets, non-theme-aware)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primary, primaryLight, primaryLighter],
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGold, accentGoldLight],
  );

  // ═══════════════════════════════════════════════════════
  // BOX SHADOWS
  // ═══════════════════════════════════════════════════════
  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> darkShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
