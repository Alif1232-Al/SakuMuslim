import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/quran_provider.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/ayat_model.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 28.0;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    AppLogger.info('SurahDetailScreen loaded: ${widget.surahNumber}');

    // Load surah detail after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuranProvider>();
      provider.loadSurahDetail(widget.surahNumber);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.detailGradient(context),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ═══════════════════════════════════════════════
              // APP BAR
              // ═══════════════════════════════════════════════
              _buildAppBar(),

              // ═══════════════════════════════════════════════
              // CONTENT
              // ═══════════════════════════════════════════════
              Expanded(
                child: _buildContent(),
              ),

              // ═══════════════════════════════════════════════
              // SETTINGS BAR
              // ═══════════════════════════════════════════════
              _buildSettingsBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Consumer<QuranProvider>(
      builder: (context, provider, child) {
        final surah = provider.currentSurah;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      surah?.nameLatin ?? 'Memuat...',
                      style: AppTextStyles.h3(color: Colors.white),
                    ),
                    if (surah != null)
                      Text(
                        '${surah.revelationId} • ${surah.totalAyat} Ayat',
                        style: AppTextStyles.caption(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Add bookmark functionality
                },
                icon: const Icon(
                  Icons.bookmark_border,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Consumer<QuranProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingDetail) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (provider.detailError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat ayat',
                  style: AppTextStyles.h4(color: Colors.white),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => provider.loadSurahDetail(widget.surahNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.card(context),
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.contentBackground(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.ayats.length,
            itemBuilder: (context, index) {
              final ayat = provider.ayats[index];
              return _buildAyatCard(ayat);
            },
          ),
        );
      },
    );
  }

  Widget _buildAyatCard(Ayat ayat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Optional: Add tap feedback
          },
          splashColor: AppColors.primary.withValues(alpha: 0.05),
          highlightColor: AppColors.primary.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ayat number badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Number badge with gradient
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${ayat.numberInSurah}',
                        style: AppTextStyles.label(color: Colors.white),
                      ),
                    ),
                    // More options
                    IconButton(
                      onPressed: () {
                        // TODO: Add share/bookmark functionality
                      },
                      icon: Icon(
                        Icons.bookmark_border_rounded,
                        color: AppColors.primary.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Arabic text - with elegant styling
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ayat.textArabic,
                    style: AppTextStyles.arabic(
                      size: _fontSize,
                      color: AppColors.textPrimary(context),
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),

                if (_showTranslation) ...[
                  const SizedBox(height: 16),

                  // Translation - with modern divider
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ayat.textTranslation,
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textSecondary(context),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Font size label
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.text_fields,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),

            // Font size slider
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primarySurface,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: _fontSize,
                      min: 20,
                      max: 40,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Toggle translation button
            GestureDetector(
              onTap: () {
                setState(() {
                  _showTranslation = !_showTranslation;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _showTranslation
                      ? AppColors.primary
                      : AppColors.primarySurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showTranslation ? Icons.visibility : Icons.visibility_off,
                      size: 16,
                      color: _showTranslation ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Terjemahan',
                      style: AppTextStyles.caption(
                        color: _showTranslation ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
