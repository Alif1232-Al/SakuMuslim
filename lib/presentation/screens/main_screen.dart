import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/quran_provider.dart';
import 'quran/quran_index_screen.dart';
import 'quran/surah_detail_screen.dart';
import 'prayer_times/prayer_times_screen.dart';
import 'tasbih/tasbih_screen.dart';
import 'zakat/zakat_screen.dart';
import 'hadith/hadith_screen.dart';
import 'kiblat/kiblat_compass_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(onNavigate: switchTab),
          const QuranIndexScreen(),
          const PrayerTimesScreen(),
          const TasbihScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1929)
              : Colors.white,
          selectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF0D47A1),
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white54
              : const Color(0xFF90A4AE),
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Al-Qur\'an'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time_rounded), label: 'Sholat'),
            BottomNavigationBarItem(icon: Icon(Icons.lens_blur_rounded), label: 'Tasbih'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Lainnya'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _HomeTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.homeGradient(context),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildGreetingCard(),
                _buildFeatureGrid(context, onNavigate),
                _buildLastReadSection(context, onNavigate),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SakuMuslim',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Asisten Ibadah Anda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.mosque, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalamu\'alaikum',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Semoga hari Anda penuh berkah',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, ValueChanged<int> onNavigate) {
    final features = [
      _FeatureItem(
        icon: Icons.menu_book_rounded,
        title: 'Al-Qur\'an',
        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
        onTap: () => onNavigate(1),
      ),
      _FeatureItem(
        icon: Icons.access_time_rounded,
        title: 'Sholat',
        gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF26A69A)]),
        onTap: () => onNavigate(2),
      ),
      _FeatureItem(
        icon: Icons.lens_blur_rounded,
        title: 'Tasbih',
        gradient: const LinearGradient(colors: [Color(0xFFC6A054), Color(0xFFE0C882)]),
        onTap: () => onNavigate(3),
      ),
      _FeatureItem(
        icon: Icons.account_balance_rounded,
        title: 'Zakat',
        gradient: const LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)]),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const ZakatScreen(),
        )),
      ),
      _FeatureItem(
        icon: Icons.auto_stories_rounded,
        title: 'Hadist',
        gradient: const LinearGradient(colors: [Color(0xFF8D6E63), Color(0xFFA1887F)]),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HadithScreen(),
        )),
      ),
      _FeatureItem(
        icon: Icons.explore_rounded,
        title: 'Kiblat',
        gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)]),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const KiblatCompassScreen(),
        )),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Fitur Utama',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return GestureDetector(
              onTap: feature.onTap,
              child: Container(
                decoration: BoxDecoration(
                  gradient: feature.gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(feature.icon, color: Colors.white, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      feature.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLastReadSection(BuildContext context, ValueChanged<int> onNavigate) {
    return Consumer<QuranProvider>(
      builder: (context, quran, child) {
        final surahName = quran.lastReadSurah?.nameLatin ?? 'Belum ada';
        final ayatNum = quran.lastReadAyat;
        final surahNum = quran.lastReadSurahNumber;
        final revelation = quran.lastReadSurah?.revelationId ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terakhir Dibaca',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigate(1),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: surahName != 'Belum ada'
                  ? () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(surahNumber: surahNum),
                    ))
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$surahNum',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surahName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ayatNum > 0 ? 'Ayat $ayatNum • $revelation' : 'Ketuk untuk mulai membaca',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: const Color(0xFF1565C0).withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });
}
