class ApiEndpoints {
  ApiEndpoints._();

  // ═══════════════════════════════════════════════════════
  // BASE URLS
  // ═══════════════════════════════════════════════════════

  static const String quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String hadithBaseUrl = 'https://api.ahmadsanusi.com/v1/hadits';
  static const String prayerTimeBaseUrl = 'https://api.aladhan.com/v1';

  // ═══════════════════════════════════════════════════════
  // QURAN API
  // ═══════════════════════════════════════════════════════

  /// Get all surah list
  /// Returns: List of 114 surahs with metadata
  static const String allSurah = '$quranBaseUrl/surah';

  /// Get specific surah with translation
  /// Parameter: [surahNumber] (1-114)
  /// Edition: id.nasr (Indonesian translation by Kemenag)
  static String surahDetail(int surahNumber) =>
      '$quranBaseUrl/surah/$surahNumber/id.nasr';

  /// Get specific ayat
  /// Parameter: [surahNumber] and [ayatNumber]
  static String ayatDetail(int surahNumber, int ayatNumber) =>
      '$quranBaseUrl/surah/$surahNumber/$ayatNumber/id.nasr';

  /// Get juz list
  static const String allJuz = '$quranBaseUrl/juz';

  /// Get specific juz
  static String juzDetail(int juzNumber) =>
      '$quranBaseUrl/juz/$juzNumber/id.nasr';

  // ═══════════════════════════════════════════════════════
  // HADITH API
  // ═══════════════════════════════════════════════════════

  /// Get all hadith books
  static const String hadithBooks = '$hadithBaseUrl/books';

  /// Get specific book
  /// Parameter: [bookName] (e.g., 'abu-dawud', 'bukhari', 'muslim')
  static String hadithBookDetail(String bookName) =>
      '$hadithBaseUrl/books/$bookName';

  /// Get specific chapter from book
  static String hadithChapter(String bookName, int chapterNumber) =>
      '$hadithBaseUrl/books/$bookName/$chapterNumber';

  // ═══════════════════════════════════════════════════════
  // PRAYER TIME API
  // ═══════════════════════════════════════════════════════

  /// Get prayer times by city
  /// Parameters: [city], [country], [method] (calculation method)
  static String prayerTimesByCity({
    required String city,
    required String country,
    int method = 20, // Kemenag RI method
  }) {
    return '$prayerTimeBaseUrl/timesByCity'
        '?city=$city'
        '&country=$country'
        '&method=$method';
  }

  /// Get prayer times by coordinates
  /// Parameters: [latitude], [longitude], [method]
  static String prayerTimesByLocation({
    required double latitude,
    required double longitude,
    int method = 20,
  }) {
    return '$prayerTimeBaseUrl/timings'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$method';
  }

  // ═══════════════════════════════════════════════════════
  // PRAYER TIME CALCULATION METHODS
  // ═══════════════════════════════════════════════════════

  /// Calculation method IDs
  static const int methodKemenag = 20;
  static const int methodMWL = 1;
  static const int methodISNA = 2;
  static const int methodEgypt = 5;
  static const int methodKarachi = 7;
}
