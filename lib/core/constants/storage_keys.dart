class StorageKeys {
  StorageKeys._();

  // ═══════════════════════════════════════════════════════
  // HIVE BOX NAMES
  // ═══════════════════════════════════════════════════════

  static const String boxUserPreferences = 'sakumuslim_user_preferences';
  static const String boxBookmarks = 'sakumuslim_bookmarks';
  static const String boxQuranCache = 'sakumuslim_quran_cache';
  static const String boxHadithCache = 'sakumuslim_hadith_cache';
  static const String boxPrayerTimes = 'sakumuslim_prayer_times';

  // ═══════════════════════════════════════════════════════
  // USER PREFERENCES KEYS
  // ═══════════════════════════════════════════════════════

  static const String keyThemeMode = 'theme_mode';
  static const String keyFontSizeArabic = 'font_size_arabic';
  static const String keyFontSizeTranslation = 'font_size_translation';
  static const String keyLastReadSurah = 'last_read_surah';
  static const String keyLastReadAyat = 'last_read_ayat';
  static const String keyDefaultCity = 'default_city';
  static const String keyDefaultCountry = 'default_country';
  static const String keyCalculationMethod = 'calculation_method';
  static const String keyShowTranslation = 'show_translation';
  static const String keyShowTransliteration = 'show_transliteration';

  // Notification keys
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyPerPrayerEnabled = 'per_prayer_enabled';

  // ═══════════════════════════════════════════════════════
  // BOOKMARK KEYS
  // ═══════════════════════════════════════════════════════

  static const String bookmarkId = 'bookmark_id';
  static const String bookmarkType = 'type'; // quran, hadith, doa
  static const String bookmarkSurahNumber = 'surah_number';
  static const String bookmarkAyatNumber = 'ayat_number';
  static const String bookmarkCreatedAt = 'created_at';

  // ═══════════════════════════════════════════════════════
  // CACHE KEYS
  // ═══════════════════════════════════════════════════════

  static const String cacheTimestamp = 'cache_timestamp';
  static const String cacheData = 'cache_data';
  static const String cacheExpiry = 'cache_expiry'; // in hours

  // ═══════════════════════════════════════════════════════
  // DEFAULT VALUES
  // ═══════════════════════════════════════════════════════

  static const double defaultFontSizeArabic = 28.0;
  static const double defaultFontSizeTranslation = 14.0;
  static const String defaultCity = 'Jakarta';
  static const String defaultCountry = 'Indonesia';
  static const int defaultCalculationMethod = 20; // Kemenag
  static const int defaultCacheExpiryHours = 24;
}
