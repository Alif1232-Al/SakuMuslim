import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../data/models/surah_model.dart';
import '../data/models/ayat_model.dart';
import '../data/repositories/quran_repository.dart';
import '../core/constants/storage_keys.dart';
import '../core/utils/app_logger.dart';

class QuranProvider extends ChangeNotifier {
  final QuranRepository _repository;
  late Box _prefsBox;

  QuranProvider({QuranRepository? repository})
      : _repository = repository ?? QuranRepository() {
    _prefsBox = Hive.box(StorageKeys.boxUserPreferences);
    _loadLastRead();
  }

  // ═══════════════════════════════════════════════════════
  // STATE: SURAH LIST
  // ═══════════════════════════════════════════════════════
  List<Surah> _surahs = [];
  List<Surah> get surahs => _surahs;

  bool _isLoadingSurahs = false;
  bool get isLoadingSurahs => _isLoadingSurahs;

  String? _surahsError;
  String? get surahsError => _surahsError;

  // ═══════════════════════════════════════════════════════
  // STATE: SURAH DETAIL
  // ═══════════════════════════════════════════════════════
  Surah? _currentSurah;
  Surah? get currentSurah => _currentSurah;

  List<Ayat> _ayats = [];
  List<Ayat> get ayats => _ayats;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  String? _detailError;
  String? get detailError => _detailError;

  // ═══════════════════════════════════════════════════════
  // STATE: SEARCH
  // ═══════════════════════════════════════════════════════
  List<Surah> _filteredSurahs = [];
  List<Surah> get filteredSurahs => _filteredSurahs;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // ═══════════════════════════════════════════════════════
  // STATE: LAST READ (persisted to Hive)
  // ═══════════════════════════════════════════════════════
  int _lastReadSurahNumber = 1;
  int get lastReadSurahNumber => _lastReadSurahNumber;

  int _lastReadAyat = 0;
  int get lastReadAyat => _lastReadAyat;

  Surah? _lastReadSurah;
  Surah? get lastReadSurah => _lastReadSurah;

  // ═══════════════════════════════════════════════════════
  // METHODS
  // ═══════════════════════════════════════════════════════

  void _loadLastRead() {
    _lastReadSurahNumber = _prefsBox.get(StorageKeys.keyLastReadSurah, defaultValue: 1);
    _lastReadAyat = _prefsBox.get(StorageKeys.keyLastReadAyat, defaultValue: 0);
  }

  Future<void> _saveLastRead() async {
    await _prefsBox.put(StorageKeys.keyLastReadSurah, _lastReadSurahNumber);
    await _prefsBox.put(StorageKeys.keyLastReadAyat, _lastReadAyat);
  }

  void _resolveLastReadSurah() {
    if (_surahs.isNotEmpty) {
      try {
        _lastReadSurah = _surahs.firstWhere((s) => s.number == _lastReadSurahNumber);
      } catch (_) {
        _lastReadSurah = _surahs.first;
        _lastReadSurahNumber = _surahs.first.number;
      }
    }
  }

  Future<void> loadSurahs() async {
    if (_isLoadingSurahs) return;

    _isLoadingSurahs = true;
    _surahsError = null;
    notifyListeners();

    try {
      _surahs = await _repository.getAllSurahs();
      _filteredSurahs = _surahs;
      _resolveLastReadSurah();
      AppLogger.info('Loaded ${_surahs.length} surahs');
    } catch (e) {
      _surahsError = e.toString();
      AppLogger.error('Error loading surahs: $e');
    } finally {
      _isLoadingSurahs = false;
      notifyListeners();
    }
  }

  Future<void> loadSurahDetail(int surahNumber) async {
    if (_isLoadingDetail) return;

    _isLoadingDetail = true;
    _detailError = null;
    notifyListeners();

    try {
      final detail = await _repository.getSurahDetail(surahNumber);
      _currentSurah = detail.surah;
      _ayats = detail.ayats;

      _lastReadSurah = detail.surah;
      _lastReadSurahNumber = surahNumber;
      _lastReadAyat = 1;
      await _saveLastRead();

      AppLogger.info('Loaded surah ${detail.surah.nameLatin} with ${detail.ayats.length} ayats');
    } catch (e) {
      _detailError = e.toString();
      AppLogger.error('Error loading surah detail: $e');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> setLastRead(int surahNumber, int ayatNumber) async {
    _lastReadSurahNumber = surahNumber;
    _lastReadAyat = ayatNumber;
    _resolveLastReadSurah();
    await _saveLastRead();
    notifyListeners();
  }

  void searchSurahs(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredSurahs = _surahs;
      _isSearching = false;
    } else {
      _isSearching = true;
      final lowerQuery = query.toLowerCase();
      _filteredSurahs = _surahs.where((surah) {
        return surah.nameLatin.toLowerCase().contains(lowerQuery) ||
            surah.nameArabic.contains(query) ||
            surah.number.toString() == query ||
            surah.nameEnglish.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredSurahs = _surahs;
    _isSearching = false;
    notifyListeners();
  }

  Surah? getSurahByNumber(int number) {
    try {
      return _surahs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }
}
