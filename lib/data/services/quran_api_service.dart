import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/app_logger.dart';
import '../models/surah_model.dart';
import '../models/ayat_model.dart';

class QuranApiService {
  final Dio _dio;

  QuranApiService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    baseUrl: ApiEndpoints.quranBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Fetch all 114 surahs
  Future<List<Surah>> getAllSurah() async {
    try {
      AppLogger.info('Fetching all surahs...');
      final response = await _dio.get('/surah');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final surahs = data.map((json) => Surah.fromJson(json)).toList();
        AppLogger.info('Fetched ${surahs.length} surahs');
        return surahs;
      } else {
        throw Exception('Failed to load surahs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching surahs: ${e.message}', e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected error fetching surahs: $e');
      rethrow;
    }
  }

  /// Fetch surah detail with ayats (Arabic + Translation)
  Future<SurahDetailResponse> getSurahDetail(int surahNumber) async {
    try {
      AppLogger.info('Fetching surah detail: $surahNumber');

      // Fetch Arabic text and translation in parallel
      final results = await Future.wait([
        _dio.get('/surah/$surahNumber'),
        _dio.get('/surah/$surahNumber/id.indonesian'),
      ]);

      final arabicResponse = results[0];
      final translationResponse = results[1];

      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = arabicResponse.data['data'];
        final translationData = translationResponse.data['data'];

        final surah = Surah.fromJson(arabicData);

        // Combine Arabic and translation
        final arabicAyahs = arabicData['ayahs'] as List;
        final translationAyahs = translationData['ayahs'] as List;

        final ayats = <Ayat>[];
        for (int i = 0; i < arabicAyahs.length; i++) {
          final arabicAyah = arabicAyahs[i];
          final translationText = i < translationAyahs.length
              ? translationAyahs[i]['text'] ?? ''
              : '';

          ayats.add(Ayat.fromJson(arabicAyah, translation: translationText));
        }

        AppLogger.info('Fetched surah ${surah.nameLatin} with ${ayats.length} ayats');
        return SurahDetailResponse(surah: surah, ayats: ayats);
      } else {
        throw Exception('Failed to load surah detail');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching surah detail: ${e.message}', e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected error fetching surah detail: $e');
      rethrow;
    }
  }
}

/// Response class for surah detail
class SurahDetailResponse {
  final Surah surah;
  final List<Ayat> ayats;

  const SurahDetailResponse({
    required this.surah,
    required this.ayats,
  });
}
