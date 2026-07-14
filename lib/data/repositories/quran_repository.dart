import 'package:hive/hive.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/app_logger.dart';
import '../models/surah_model.dart';
import '../models/ayat_model.dart';
import '../services/quran_api_service.dart';

class QuranRepository {
  final QuranApiService _apiService;

  QuranRepository({QuranApiService? apiService})
      : _apiService = apiService ?? QuranApiService();

  /// Get all surahs (from cache or API)
  Future<List<Surah>> getAllSurahs() async {
    try {
      // Try to get from cache first
      final cachedSurahs = await _getCachedSurahs();
      if (cachedSurahs.isNotEmpty) {
        AppLogger.info('Loaded ${cachedSurahs.length} surahs from cache');
        return cachedSurahs;
      }

      // Fetch from API
      AppLogger.info('Fetching surahs from API...');
      final surahs = await _apiService.getAllSurah();

      // Cache the result
      await _cacheSurahs(surahs);

      return surahs;
    } catch (e) {
      AppLogger.error('Error getting all surahs: $e');
      rethrow;
    }
  }

  /// Get surah detail with ayats
  Future<SurahDetailResponse> getSurahDetail(int surahNumber) async {
    try {
      // Try to get from cache first
      final cachedDetail = await _getCachedSurahDetail(surahNumber);
      if (cachedDetail != null) {
        AppLogger.info('Loaded surah $surahNumber from cache');
        return cachedDetail;
      }

      // Fetch from API
      AppLogger.info('Fetching surah $surahNumber from API...');
      final detail = await _apiService.getSurahDetail(surahNumber);

      // Cache the result
      await _cacheSurahDetail(surahNumber, detail);

      return detail;
    } catch (e) {
      AppLogger.error('Error getting surah detail: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // CACHE METHODS
  // ═══════════════════════════════════════════════════════

  Future<List<Surah>> _getCachedSurahs() async {
    try {
      final box = await Hive.openBox(StorageKeys.boxQuranCache);
      final cachedData = box.get('all_surahs');

      if (cachedData != null && cachedData is List) {
        return cachedData.map((json) => Surah.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error reading cached surahs: $e');
      return [];
    }
  }

  Future<void> _cacheSurahs(List<Surah> surahs) async {
    try {
      final box = await Hive.openBox(StorageKeys.boxQuranCache);
      await box.put('all_surahs', surahs.map((s) => s.toJson()).toList());
      await box.put('surahs_cache_timestamp', DateTime.now().millisecondsSinceEpoch);
      AppLogger.info('Cached ${surahs.length} surahs');
    } catch (e) {
      AppLogger.error('Error caching surahs: $e');
    }
  }

  Future<SurahDetailResponse?> _getCachedSurahDetail(int surahNumber) async {
    try {
      final box = await Hive.openBox(StorageKeys.boxQuranCache);
      final cachedData = box.get('surah_$surahNumber');

      if (cachedData != null && cachedData is Map) {
        final surah = Surah.fromJson(cachedData['surah']);
        final ayats = (cachedData['ayats'] as List)
            .map((json) => Ayat.fromJson(json))
            .toList();
        return SurahDetailResponse(surah: surah, ayats: ayats);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error reading cached surah detail: $e');
      return null;
    }
  }

  Future<void> _cacheSurahDetail(int surahNumber, SurahDetailResponse detail) async {
    try {
      final box = await Hive.openBox(StorageKeys.boxQuranCache);
      await box.put('surah_$surahNumber', {
        'surah': detail.surah.toJson(),
        'ayats': detail.ayats.map((a) => a.toJson()).toList(),
      });
      AppLogger.info('Cached surah $surahNumber');
    } catch (e) {
      AppLogger.error('Error caching surah detail: $e');
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(StorageKeys.boxQuranCache);
      await box.clear();
      AppLogger.info('Quran cache cleared');
    } catch (e) {
      AppLogger.error('Error clearing cache: $e');
    }
  }
}
