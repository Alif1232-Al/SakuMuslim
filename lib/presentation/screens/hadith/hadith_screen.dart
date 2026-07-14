import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/services/hadith_service.dart';
import 'hadith_detail_screen.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  late final List<Map<String, dynamic>> _hadithBooks;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AppLogger.info('HadithScreen loaded');
    _hadithBooks = HadithService.hadithBooks;
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await HadithService().getBooks();
      if (mounted && books.isNotEmpty) {
        setState(() {
          _hadithBooks.clear();
          _hadithBooks.addAll(books);
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading books: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.hadithGradient(context),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'Koleksi Hadist',
              style: AppTextStyles.h3(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.contentBackground(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hadithBooks.length,
        itemBuilder: (context, index) {
          final book = _hadithBooks[index];
          return _buildBookCard(book);
        },
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final icon = _getBookIcon(book['id']);
    final color = _getBookColor(book['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HadithDetailScreen(
                  bookId: book['id'],
                  bookName: book['name'],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder(context), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['name'] as String,
                        style: AppTextStyles.h4(color: AppColors.textPrimary(context)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${book['total']} Hadis',
                        style: AppTextStyles.caption(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary(context).withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getBookIcon(String bookId) {
    switch (bookId) {
      case 'shahih_bukhari':
        return Icons.library_books;
      case 'shahih_muslim':
        return Icons.menu_book;
      case 'sunan_abu_daud':
        return Icons.book;
      case 'sunan_tirmidzi':
        return Icons.chrome_reader_mode;
      case 'sunan_nasai':
        return Icons.book_outlined;
      case 'sunan_ibnu_majah':
        return Icons.auto_stories_outlined;
      case 'musnad_ahmad':
        return Icons.auto_stories;
      case 'riyadhus_shalihin':
        return Icons.local_library;
      default:
        return Icons.book;
    }
  }

  Color _getBookColor(String bookId) {
    switch (bookId) {
      case 'shahih_bukhari':
        return AppColors.secondary;
      case 'shahih_muslim':
        return const Color(0xFF5C6BC0);
      case 'sunan_abu_daud':
        return const Color(0xFF8D6E63);
      case 'sunan_tirmidzi':
        return const Color(0xFF00897B);
      case 'sunan_nasai':
        return const Color(0xFFC6A054);
      case 'sunan_ibnu_majah':
        return const Color(0xFF7B1FA2);
      case 'musnad_ahmad':
        return AppColors.primary;
      case 'riyadhus_shalihin':
        return const Color(0xFF2E7D32);
      default:
        return AppColors.primary;
    }
  }
}
