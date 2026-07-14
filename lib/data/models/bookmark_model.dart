import 'package:hive/hive.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/app_logger.dart';

class BookmarkModel {
  final String id;
  final String type; // quran, hadith, doa
  final int? surahNumber;
  final int? ayatNumber;
  final String? title;
  final String? subtitle;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.type,
    this.surahNumber,
    this.ayatNumber,
    this.title,
    this.subtitle,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'surahNumber': surahNumber,
      'ayatNumber': ayatNumber,
      'title': title,
      'subtitle': subtitle,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'quran',
      surahNumber: json['surahNumber'],
      ayatNumber: json['ayatNumber'],
      title: json['title'],
      subtitle: json['subtitle'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
    );
  }
}

class BookmarkProvider {
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(StorageKeys.boxBookmarks);
    AppLogger.info('Bookmark provider initialized');
  }

  List<BookmarkModel> getAllBookmarks() {
    try {
      final bookmarks = _box.values.toList();
      return bookmarks.map((json) => BookmarkModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting bookmarks: $e');
      return [];
    }
  }

  List<BookmarkModel> getBookmarksByType(String type) {
    try {
      final allBookmarks = getAllBookmarks();
      return allBookmarks.where((b) => b.type == type).toList();
    } catch (e) {
      AppLogger.error('Error getting bookmarks by type: $e');
      return [];
    }
  }

  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      await _box.put(bookmark.id, bookmark.toJson());
      AppLogger.info('Bookmark added: ${bookmark.id}');
    } catch (e) {
      AppLogger.error('Error adding bookmark: $e');
    }
  }

  Future<void> removeBookmark(String id) async {
    try {
      await _box.delete(id);
      AppLogger.info('Bookmark removed: $id');
    } catch (e) {
      AppLogger.error('Error removing bookmark: $e');
    }
  }

  bool isBookmarked(String id) {
    return _box.containsKey(id);
  }

  String generateBookmarkId(String type, int surahNumber, int ayatNumber) {
    return '${type}_${surahNumber}_$ayatNumber';
  }
}
