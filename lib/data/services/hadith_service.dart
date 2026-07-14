import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/app_logger.dart';

class HadithService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'X-API-Key': 'ask_ltv98GSHrhI3OGFpPzRR1R_Gq0rvjyVLXbKpmoXEHsY',
    },
  ));
  static const String _baseUrl = ApiEndpoints.hadithBaseUrl;

  /// Available hadith books with their details
  static const List<Map<String, dynamic>> hadithBooks = [
    {
      'id': 'shahih_bukhari',
      'name': 'Shahih Bukhari',
      'total': 7008,
      'description': 'Hadis shahih riwayat Imam Bukhari',
    },
    {
      'id': 'shahih_muslim',
      'name': 'Shahih Muslim',
      'total': 5362,
      'description': 'Hadis shahih riwayat Imam Muslim',
    },
    {
      'id': 'sunan_abu_daud',
      'name': 'Sunan Abu Daud',
      'total': 4590,
      'description': 'Hadis riwayat Imam Abu Dawud',
    },
    {
      'id': 'sunan_tirmidzi',
      'name': 'Sunan Tirmidzi',
      'total': 3891,
      'description': 'Hadis riwayat Imam Tirmidzi',
    },
    {
      'id': 'sunan_nasai',
      'name': 'Sunan Nasa\'i',
      'total': 5662,
      'description': 'Hadis riwayat Imam Nasa\'i',
    },
    {
      'id': 'sunan_ibnu_majah',
      'name': 'Sunan Ibnu Majah',
      'total': 4332,
      'description': 'Hadis riwayat Imam Ibnu Majah',
    },
    {
      'id': 'musnad_ahmad',
      'name': 'Musnad Ahmad',
      'total': 26363,
      'description': 'Hadis riwayat Imam Ahmad',
    },
    {
      'id': 'riyadhus_shalihin',
      'name': 'Riyadhus Shalihin',
      'total': 371,
      'description': 'Kitab hadis pilihan Imam Nawawi',
    },
  ];

  /// Get list of available hadith books
  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final response = await _dio.get(_baseUrl);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final books = (data['kitab'] as List).map<Map<String, dynamic>>((b) {
          return {
            'id': b['slug'],
            'name': b['nama'],
            'total': b['jumlah'],
          };
        }).toList();
        AppLogger.info('Loaded ${books.length} hadith books');
        return books;
      }
      return hadithBooks;
    } catch (e) {
      AppLogger.error('Error loading hadith books: $e');
      return hadithBooks;
    }
  }

  /// Get a specific hadith by book and number
  Future<Map<String, dynamic>?> getHadith(String bookId, int hadithNumber) async {
    try {
      final response = await _dio.get('$_baseUrl/$bookId/$hadithNumber');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return {
          'nomor': data['nomor'],
          'kitab': data['kitab'],
          'arab': data['arab'] ?? '',
          'terjemah': data['terjemah'] ?? '',
          'has_terjemah': data['has_terjemah'] ?? false,
        };
      }
      return null;
    } catch (e) {
      AppLogger.error('Error loading hadith $bookId/$hadithNumber: $e');
      return null;
    }
  }

  /// Get multiple hadiths from a book (paginated)
  Future<List<Map<String, dynamic>>> getHadiths({
    required String bookId,
    required int page,
    int perPage = 20,
  }) async {
    try {
      final startIndex = (page - 1) * perPage + 1;
      final endIndex = startIndex + perPage;

      // Fetch all hadiths in parallel for speed
      final futures = <Future<Map<String, dynamic>?>>[];
      for (int i = startIndex; i < endIndex; i++) {
        futures.add(getHadith(bookId, i));
      }
      final results = await Future.wait(futures);

      final hadiths = <Map<String, dynamic>>[];
      for (final h in results) {
        if (h != null) {
          hadiths.add(h);
        } else {
          break; // Stop at first null (end of book)
        }
      }

      AppLogger.info('Loaded ${hadiths.length} hadiths from $bookId page $page');
      return hadiths;
    } catch (e) {
      AppLogger.error('Error loading hadiths: $e');
      return [];
    }
  }

  /// Search hadiths by keyword
  Future<List<Map<String, dynamic>>> searchHadiths({
    required String keyword,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': keyword,
          'limit': limit,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final hadiths = data.map<Map<String, dynamic>>((h) {
          return {
            'nomor': h['nomor'],
            'kitab': h['kitab'],
            'arab': h['arab'] ?? '',
            'terjemah': h['terjemah'] ?? '',
            'has_terjemah': h['has_terjemah'] ?? false,
          };
        }).toList();
        AppLogger.info('Found ${hadiths.length} hadiths for keyword: $keyword');
        return hadiths;
      }
      return [];
    } catch (e) {
      AppLogger.error('Error searching hadiths: $e');
      return [];
    }
  }
}
