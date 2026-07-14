import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/services/prayer_notification_service.dart';
import '../../../providers/settings_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Map<String, String>? _prayerTimes;
  bool _isLoading = true;
  String? _error;
  late String _city;
  late int _method;

  static const Map<String, String> _cities = {
    'Jakarta': 'Jakarta',
    'Surabaya': 'Surabaya',
    'Bandung': 'Bandung',
    'Medan': 'Medan',
    'Makassar': 'Makassar',
    'Yogyakarta': 'Yogyakarta',
    'Semarang': 'Semarang',
    'Palembang': 'Palembang',
    'Tangerang': 'Tangerang',
    'Depok': 'Depok',
    'Bekasi': 'Bekasi',
    'Malang': 'Malang',
    'Padang': 'Padang',
    'Banjarmasin': 'Banjarmasin',
    'Bogor': 'Bogor',
    'Batam': 'Batam',
    'Pekanbaru': 'Pekanbaru',
    'Manado': 'Manado',
    'Pontianak': 'Pontianak',
    'Balikpapan': 'Balikpapan',
    'Samarinda': 'Samarinda',
    'Jambi': 'Jambi',
    'Mataram': 'Mataram',
    'Kupang': 'Kupang',
    'Ambon': 'Ambon',
    'Jayapura': 'Jayapura',
    'Sorong': 'Sorong',
    'Denpasar': 'Denpasar',
    'Solo': 'Surakarta',
  };

  static const Map<int, String> _methods = {
    1: 'MWL (Muslim World League)',
    2: 'ISNA (North America)',
    5: 'Egypt',
    7: 'Karachi',
    20: 'Kemenag RI',
  };

  @override
  void initState() {
    super.initState();
    _loadFromSettings();
    _fetchPrayerTimes();
  }

  void _loadFromSettings() {
    try {
      if (mounted) {
        final settings = context.read<SettingsProvider>();
        _city = settings.defaultCity;
        _method = settings.calculationMethod;
      }
    } catch (_) {
      _city = 'Jakarta';
      _method = 20;
    }
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = Dio();
      final url = '${ApiEndpoints.prayerTimeBaseUrl}/timingsByCity'
          '?city=$_city'
          '&country=Indonesia'
          '&method=$_method';
      AppLogger.info('Fetching prayer times: $url');

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final timings = data['timings'];
        final meta = data['meta'];
        final apiTimezone = meta['timezone'] ?? '';

        setState(() {
          _prayerTimes = {
            'Subuh': _formatTime(timings['Fajr']),
            'Terbit': _formatTime(timings['Sunrise']),
            'Dzuhur': _formatTime(timings['Dhuhr']),
            'Ashar': _formatTime(timings['Asr']),
            'Maghrib': _formatTime(timings['Maghrib']),
            'Isya': _formatTime(timings['Isha']),
          };
          _isLoading = false;
        });

        if (mounted) {
          final settings = context.read<SettingsProvider>();
          PrayerNotificationService.instance.schedulePrayerTimes(
            prayerTimes: _prayerTimes!,
            settings: settings,
          );
        }

        AppLogger.info('Prayer times loaded for $_city (tz: $apiTimezone)');
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat jadwal sholat untuk $_city';
        _isLoading = false;
      });
      AppLogger.error('Error fetching prayer times for $_city: $e');
    }
  }

  String _formatTime(String time) {
    return time.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();
  }

  void _onCityChanged(String? newCity) {
    if (newCity == null || newCity == _city) return;
    setState(() => _city = newCity);
    // Save to settings so it persists
    context.read<SettingsProvider>().setDefaultCity(newCity);
    _fetchPrayerTimes();
  }

  void _onMethodChanged(int? newMethod) {
    if (newMethod == null || newMethod == _method) return;
    setState(() => _method = newMethod);
    context.read<SettingsProvider>().setCalculationMethod(newMethod);
    _fetchPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.prayerGradient(context),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
              _buildCitySelector(),
              _buildMethodSelector(),
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
              'Waktu Sholat',
              style: AppTextStyles.h3(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _cities.containsKey(_city) ? _city : null,
                hint: Text(
                  _city,
                  style: AppTextStyles.bodyMedium(color: Colors.white),
                ),
                dropdownColor: AppColors.secondary,
                style: AppTextStyles.bodyMedium(color: Colors.white),
                isExpanded: true,
                items: _cities.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _onCityChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _method,
                dropdownColor: AppColors.secondary,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
                isExpanded: true,
                items: _methods.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: _onMethodChanged,
              ),
            ),
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: AppTextStyles.h4(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchPrayerTimes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface(context),
                  foregroundColor: AppColors.secondary,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.contentBackground(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _prayerTimes?.length ?? 0,
        itemBuilder: (context, index) {
          final entry = _prayerTimes!.entries.elementAt(index);
          return _buildPrayerTimeTile(entry.key, entry.value, index);
        },
      ),
    );
  }

  Widget _buildPrayerTimeTile(String name, String time, int index) {
    final isCurrentPrayer = _isCurrentPrayer(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentPrayer
            ? AppColors.secondary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPrayer
              ? AppColors.secondary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentPrayer
                  ? AppColors.secondary.withValues(alpha: 0.2)
                  : AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _getPrayerIcon(name),
                color: AppColors.secondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.h4(
                color: isCurrentPrayer
                    ? AppColors.secondary
                    : AppColors.textPrimary(context),
              ),
            ),
          ),
          Text(
            time,
            style: AppTextStyles.prayerTime(
              color: isCurrentPrayer
                  ? AppColors.secondary
                  : AppColors.textPrimary(context),
            ),
          ),
          if (isCurrentPrayer) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sekarang',
                style: AppTextStyles.caption(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isCurrentPrayer(String name) {
    if (_prayerTimes == null) return false;

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final times = _prayerTimes!.entries.toList();
    final currentIndex = times.indexWhere((e) => e.key == name);

    if (currentIndex == -1) return false;

    final currentPrayerTime = times[currentIndex].value;

    if (name == 'Isya') {
      return currentTime.compareTo(currentPrayerTime) >= 0;
    }

    if (name == 'Subuh') {
      final terbitIndex = times.indexWhere((e) => e.key == 'Terbit');
      if (terbitIndex != -1) {
        final terbitTime = times[terbitIndex].value;
        return currentTime.compareTo('00:00') >= 0 &&
            currentTime.compareTo(terbitTime) < 0;
      }
      return currentTime.compareTo('00:00') >= 0 &&
          currentTime.compareTo('07:00') < 0;
    }

    if (name == 'Terbit') {
      final subuhIndex = times.indexWhere((e) => e.key == 'Subuh');
      if (subuhIndex != -1) {
        final subuhTime = times[subuhIndex].value;
        return currentTime.compareTo(subuhTime) >= 0 &&
            currentTime.compareTo(currentPrayerTime) < 0;
      }
      return false;
    }

    final nextIndex = currentIndex + 1;
    if (nextIndex < times.length) {
      final nextPrayerTime = times[nextIndex].value;
      return currentTime.compareTo(currentPrayerTime) >= 0 &&
          currentTime.compareTo(nextPrayerTime) < 0;
    }

    return currentTime.compareTo(currentPrayerTime) >= 0;
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'Subuh':
        return Icons.nightlight_round;
      case 'Terbit':
        return Icons.wb_sunny_outlined;
      case 'Dzuhur':
        return Icons.wb_sunny;
      case 'Ashar':
        return Icons.wb_cloudy;
      case 'Maghrib':
        return Icons.wb_twilight;
      case 'Isya':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
