import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/app_logger.dart';
import '../../../providers/quran_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/services/prayer_notification_service.dart';
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

class _HomeTab extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const _HomeTab({required this.onNavigate});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  Map<String, String>? _prayerTimes;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final settings = context.read<SettingsProvider>();
      final dio = Dio();
      String url;

      if (settings.useGpsLocation && settings.gpsLatitude != 0 && settings.gpsLongitude != 0) {
        url = '${ApiEndpoints.prayerTimeBaseUrl}/timings'
            '?latitude=${settings.gpsLatitude}'
            '&longitude=${settings.gpsLongitude}'
            '&method=${settings.calculationMethod}';
      } else {
        url = '${ApiEndpoints.prayerTimeBaseUrl}/timingsByCity'
            '?city=${Uri.encodeComponent(settings.defaultCity)}'
            '&country=Indonesia'
            '&method=${settings.calculationMethod}';
      }

      final response = await dio.get(url);

      if (response.statusCode == 200 && mounted) {
        final timings = response.data['data']['timings'];
        setState(() {
          _prayerTimes = {
            'Subuh': _fmt(timings['Fajr']),
            'Terbit': _fmt(timings['Sunrise']),
            'Dzuhur': _fmt(timings['Dhuhr']),
            'Ashar': _fmt(timings['Asr']),
            'Maghrib': _fmt(timings['Maghrib']),
            'Isya': _fmt(timings['Isha']),
          };
        });
      }
    } catch (e) {
      AppLogger.error('Home prayer fetch error: $e');
    }
  }

  String _fmt(String t) => t.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getNextPrayerInfo() {
    if (_prayerTimes == null) return 'Memuat jadwal...';

    final now = DateTime.now();
    final hhmm = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final order = ['Subuh', 'Terbit', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    for (final name in order) {
      final time = _prayerTimes![name];
      if (time != null && hhmm.compareTo(time) < 0) {
        return '$name • ${_countdown(now, time)}';
      }
    }
    return 'Isya telah lewat';
  }

  String _countdown(DateTime now, String target) {
    final parts = target.split(':');
    if (parts.length != 2) return '';
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    var targetDt = DateTime(now.year, now.month, now.day, h, m);
    if (targetDt.isBefore(now)) targetDt = targetDt.add(const Duration(days: 1));
    final diff = targetDt.difference(now);
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    if (hours > 0) return '${hours}j ${mins}m lagi';
    return '${mins}m lagi';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.homeGradient(context)),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildNextPrayerCard(),
                _buildFeatureGrid(context),
                _buildLastReadSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              _getGreeting(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showNotificationStatus(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard() {
    final settings = context.read<SettingsProvider>();
    final nextPrayer = _getNextPrayerInfo();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.mosque, color: Colors.white, size: 28),
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
                    const SizedBox(height: 2),
                    Text(
                      settings.defaultCity,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.9), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nextPrayer,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate(2),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationStatus(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final notificationService = PrayerNotificationService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: settings.notificationsEnabled
                      ? AppColors.primary
                      : AppColors.textSecondary(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi Sholat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        settings.notificationsEnabled
                            ? 'Aktif - Alarm 2 menit sebelum waktu sholat'
                            : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.notificationsEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) {
                    settings.setNotificationsEnabled(value);
                    if (value) {
                      notificationService.fetchAndSchedule(settings: settings);
                    } else {
                      notificationService.cancelAll();
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (settings.notificationsEnabled) ...[
              Text(
                'Jadwal Aktif',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              ...['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'].map(
                (prayer) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        _getPrayerIcon(prayer),
                        size: 16,
                        color: settings.isPrayerEnabled(prayer)
                            ? AppColors.primary
                            : AppColors.textSecondary(context).withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prayer,
                          style: TextStyle(
                            fontSize: 13,
                            color: settings.isPrayerEnabled(prayer)
                                ? AppColors.textPrimary(context)
                                : AppColors.textSecondary(context).withValues(alpha: 0.4),
                            fontFamily: 'Poppins',
                            decoration: settings.isPrayerEnabled(prayer)
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      Icon(
                        settings.isPrayerEnabled(prayer) ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: settings.isPrayerEnabled(prayer)
                            ? AppColors.success
                            : AppColors.error.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNavigate(2);
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Lihat Jadwal Sholat',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'Subuh':
        return Icons.nightlight_round;
      case 'Dzuhur':
        return Icons.wb_sunny;
      case 'Ashar':
        return Icons.wb_cloudy;
      case 'Maghrib':
        return Icons.wb_twilight;
      case 'Isya':
        return Icons.nights_stay;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.menu_book_rounded,
        title: 'Al-Qur\'an',
        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
        onTap: () => widget.onNavigate(1),
      ),
      _FeatureItem(
        icon: Icons.access_time_rounded,
        title: 'Sholat',
        gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF26A69A)]),
        onTap: () => widget.onNavigate(2),
      ),
      _FeatureItem(
        icon: Icons.lens_blur_rounded,
        title: 'Tasbih',
        gradient: const LinearGradient(colors: [Color(0xFFC6A054), Color(0xFFE0C882)]),
        onTap: () => widget.onNavigate(3),
      ),
      _FeatureItem(
        icon: Icons.account_balance_rounded,
        title: 'Zakat',
        gradient: const LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)]),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZakatScreen())),
      ),
      _FeatureItem(
        icon: Icons.auto_stories_rounded,
        title: 'Hadist',
        gradient: const LinearGradient(colors: [Color(0xFF8D6E63), Color(0xFFA1887F)]),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())),
      ),
      _FeatureItem(
        icon: Icons.explore_rounded,
        title: 'Kiblat',
        gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)]),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KiblatCompassScreen())),
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

  Widget _buildLastReadSection(BuildContext context) {
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
                  onPressed: () => widget.onNavigate(1),
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
                      builder: (_) => SurahDetailScreen(surahNumber: surahNum)))
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
                    Icon(Icons.arrow_forward_ios, size: 16, color: const Color(0xFF1565C0).withValues(alpha: 0.5)),
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
