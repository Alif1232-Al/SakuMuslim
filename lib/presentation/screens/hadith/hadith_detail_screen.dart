import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/hadith_service.dart';

class HadithDetailScreen extends StatefulWidget {
  final String bookId;
  final String bookName;

  const HadithDetailScreen({
    super.key,
    required this.bookId,
    required this.bookName,
  });

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  final HadithService _service = HadithService();
  final List<Map<String, dynamic>> _hadiths = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadHadiths();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreHadiths();
    }
  }

  Future<void> _loadHadiths() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hadiths = await _service.getHadiths(
        bookId: widget.bookId,
        page: 1,
        perPage: 20,
      );
      setState(() {
        _hadiths.clear();
        _hadiths.addAll(hadiths);
        _isLoading = false;
        _currentPage = 1;
        _hasMore = hadiths.length >= 20;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat hadis';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreHadiths() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final hadiths = await _service.getHadiths(
        bookId: widget.bookId,
        page: _currentPage + 1,
        perPage: 20,
      );
      setState(() {
        _hadiths.addAll(hadiths);
        _currentPage++;
        _isLoadingMore = false;
        _hasMore = hadiths.length >= 20;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
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
            child: Column(
              children: [
                Text(
                  widget.bookName,
                  style: AppTextStyles.h4(color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Terjemahan Indonesia',
                  style: AppTextStyles.bodySmall(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
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

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(_error!, style: AppTextStyles.h3(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadHadiths,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.card(context),
                foregroundColor: AppColors.isDark(context)
                    ? Colors.white
                    : const Color(0xFF5D4037),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    if (_hadiths.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada hadis ditemukan',
          style: AppTextStyles.h3(color: Colors.white),
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
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _hadiths.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _hadiths.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final hadith = _hadiths[index];
          return _buildHadithCard(hadith);
        },
      ),
    );
  }

  Widget _buildHadithCard(Map<String, dynamic> hadith) {
    final number = hadith['nomor'] ?? 0;
    final arab = hadith['arab'] ?? '';
    final terjemah = hadith['terjemah'] ?? '';
    final isDarkMode = AppColors.isDark(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : const Color(0xFF8D6E63)).withValues(alpha: isDarkMode ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with number
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8D6E63), Color(0xFFBCAAA4)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Hadis No. $number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),

            // Arabic text
            if (arab.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF3E2723).withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  arab,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    height: 2.0,
                    color: isDarkMode
                        ? const Color(0xFFEFEBE9)
                        : const Color(0xFF0D47A1),
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],

            // Indonesian translation
            if (terjemah.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                terjemah,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.8,
                  color: AppColors.textPrimary(context),
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
