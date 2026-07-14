import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
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
  bool _isDetectingLocation = false;
  String? _error;
  late String _city;
  late int _method;
  bool _usingGps = false;

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

  static const Map<String, double> _cityLat = {
    'Jakarta': -6.2088,
    'Surabaya': -7.2575,
    'Bandung': -6.9175,
    'Medan': 3.5952,
    'Makassar': -5.1477,
    'Yogyakarta': -7.7956,
    'Semarang': -6.9666,
    'Palembang': -2.9761,
    'Tangerang': -6.1781,
    'Depok': -6.4025,
    'Bekasi': -6.2349,
    'Malang': -7.9666,
    'Padang': -0.9471,
    'Banjarmasin': -3.3186,
    'Bogor': -6.5971,
    'Batam': 1.0456,
    'Pekanbaru': 0.5071,
    'Manado': 1.4748,
    'Pontianak': -0.0263,
    'Balikpapan': -1.2654,
    'Samarinda': -0.4948,
    'Jambi': -1.4852,
    'Mataram': -8.5833,
    'Kupang': -10.1772,
    'Ambon': -3.6954,
    'Jayapura': -2.5916,
    'Sorong': -0.8812,
    'Denpasar': -8.6705,
    'Solo': -7.5755,
  };

  static const Map<String, double> _cityLng = {
    'Jakarta': 106.8456,
    'Surabaya': 112.7521,
    'Bandung': 107.6191,
    'Medan': 98.6722,
    'Makassar': 119.4327,
    'Yogyakarta': 110.3642,
    'Semarang': 110.4203,
    'Palembang': 104.7754,
    'Tangerang': 106.6319,
    'Depok': 106.8451,
    'Bekasi': 106.9896,
    'Malang': 112.6304,
    'Padang': 100.3935,
    'Banjarmasin': 114.5927,
    'Bogor': 106.8341,
    'Batam': 104.0300,
    'Pekanbaru': 101.4478,
    'Manado': 124.8421,
    'Pontianak': 109.3425,
    'Balikpapan': 116.8391,
    'Samarinda': 117.1535,
    'Jambi': 103.6381,
    'Mataram': 116.0833,
    'Kupang': 123.6000,
    'Ambon': 128.1914,
    'Jayapura': 140.7189,
    'Sorong': 131.3615,
    'Denpasar': 115.2167,
    'Solo': 110.8261,
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
        _usingGps = settings.useGpsLocation;
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
      final settings = context.read<SettingsProvider>();
      final dio = Dio();
      String url;

      if (_usingGps && settings.gpsLatitude != 0 && settings.gpsLongitude != 0) {
        url = '${ApiEndpoints.prayerTimeBaseUrl}/timings'
            '?latitude=${settings.gpsLatitude}'
            '&longitude=${settings.gpsLongitude}'
            '&method=$_method';
      } else {
        url = '${ApiEndpoints.prayerTimeBaseUrl}/timingsByCity'
            '?city=${Uri.encodeComponent(_city)}'
            '&country=Indonesia'
            '&method=$_method';
      }

      AppLogger.info('Fetching prayer times: $url');
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final timings = data['timings'];
        final meta = data['meta'];

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
          PrayerNotificationService.instance.schedulePrayerTimes(
            prayerTimes: _prayerTimes!,
            settings: settings,
          );
        }

        final tz = meta['timezone'] ?? '';
        AppLogger.info('Prayer times loaded for $_city (tz: $tz)');
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
    setState(() {
      _city = newCity;
      _usingGps = false;
    });
    context.read<SettingsProvider>().setDefaultCity(newCity);
    _fetchPrayerTimes();
  }

  void _onMethodChanged(int? newMethod) {
    if (newMethod == null || newMethod == _method) return;
    setState(() => _method = newMethod);
    context.read<SettingsProvider>().setCalculationMethod(newMethod);
    _fetchPrayerTimes();
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetectingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Layanan lokasi tidak aktif. Aktifkan GPS di pengaturan HP.');
        setState(() => _isDetectingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Izin lokasi ditolak. Berikan izin di pengaturan.');
          setState(() => _isDetectingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Izin lokasi ditolak permanen. Buka pengaturan HP untuk mengubah.');
        setState(() => _isDetectingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;
      final cityName = _findNearestCity(lat, lng);

      if (mounted) {
        final settings = context.read<SettingsProvider>();
        await settings.setGpsLocation(lat, lng, cityName);

        setState(() {
          _city = cityName;
          _usingGps = true;
        });

        _showSnackBar('Lokasi terdeteksi: $cityName');
        _fetchPrayerTimes();
      }
    } catch (e) {
      AppLogger.error('GPS detection error: $e');
      _showSnackBar('Gagal mendeteksi lokasi. Coba pilih kota manual.');
    } finally {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  String _findNearestCity(double lat, double lng) {
    String nearest = 'Jakarta';
    double minDist = double.infinity;

    for (final entry in _cityLat.entries) {
      final cityLat = entry.value;
      final cityLng = _cityLng[entry.key] ?? 0;
      final dist = _haversine(lat, lng, cityLat, cityLng);
      if (dist < minDist) {
        minDist = dist;
        nearest = entry.key;
      }
    }
    return nearest;
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = pow(sin(dLat / 2), 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * pow(sin(dLng / 2), 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * pi / 180;

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.prayerGradient(context)),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
              _buildGpsButton(),
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

  Widget _buildGpsButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isDetectingLocation ? null : _detectLocation,
          icon: _isDetectingLocation
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  _usingGps ? Icons.my_location : Icons.location_searching,
                  color: Colors.white,
                  size: 18,
                ),
          label: Text(
            _isDetectingLocation
                ? 'Mendeteksi lokasi...'
                : _usingGps
                    ? 'Lokasi GPS aktif ($_city)'
                    : 'Gunakan Lokasi Saya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: _usingGps
                  ? Colors.greenAccent.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
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
                style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins'),
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
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
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
              Text(_error!, style: AppTextStyles.h4(color: Colors.white), textAlign: TextAlign.center),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _usingGps ? Colors.greenAccent.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(
                  _usingGps ? Icons.my_location : Icons.location_city,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _usingGps ? 'GPS: $_city' : _city,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                Text(
                  '${_prayerTimes?.length ?? 0} waktu',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _prayerTimes?.length ?? 0,
              itemBuilder: (context, index) {
                final entry = _prayerTimes!.entries.elementAt(index);
                return _buildPrayerTimeTile(entry.key, entry.value, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeTile(String name, String time, int index) {
    final isCurrentPrayer = _isCurrentPrayer(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentPrayer ? AppColors.secondary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPrayer ? AppColors.secondary.withValues(alpha: 0.3) : Colors.transparent,
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
              child: Icon(_getPrayerIcon(name), color: AppColors.secondary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.h4(
                color: isCurrentPrayer ? AppColors.secondary : AppColors.textPrimary(context),
              ),
            ),
          ),
          Text(
            time,
            style: AppTextStyles.prayerTime(
              color: isCurrentPrayer ? AppColors.secondary : AppColors.textPrimary(context),
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
              child: Text('Sekarang', style: AppTextStyles.caption(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  bool _isCurrentPrayer(String name) {
    if (_prayerTimes == null) return false;
    final now = DateTime.now();
    final hh = now.hour;
    final mm = now.minute;
    final currentMinutes = hh * 60 + mm;

    int toMinutes(String t) {
      final p = t.split(':');
      if (p.length != 2) return -1;
      return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
    }

    final subuh = toMinutes(_prayerTimes!['Subuh'] ?? '');
    final terbit = toMinutes(_prayerTimes!['Terbit'] ?? '');
    final dzuhur = toMinutes(_prayerTimes!['Dzuhur'] ?? '');
    final ashar = toMinutes(_prayerTimes!['Ashar'] ?? '');
    final maghrib = toMinutes(_prayerTimes!['Maghrib'] ?? '');
    final isya = toMinutes(_prayerTimes!['Isya'] ?? '');

    if (subuh == -1) return false;

    // After Isya (19:07+) or before midnight → Isya active
    if (name == 'Isya' && isya != -1) {
      return currentMinutes >= isya;
    }

    // Midnight (00:00) until Subuh → Subuh active
    if (name == 'Subuh') {
      return currentMinutes >= 0 && currentMinutes < subuh;
    }

    // Subuh until Terbit → Subuh active
    if (name == 'Subuh') {
      return currentMinutes >= subuh && currentMinutes < terbit;
    }

    // Terbit until Dzuhur → Terbit active
    if (name == 'Terbit') {
      if (terbit == -1 || dzuhur == -1) return false;
      return currentMinutes >= terbit && currentMinutes < dzuhur;
    }

    // Dzuhur until Ashar → Dzuhur active
    if (name == 'Dzuhur') {
      if (dzuhur == -1 || ashar == -1) return false;
      return currentMinutes >= dzuhur && currentMinutes < ashar;
    }

    // Ashar until Maghrib → Ashar active
    if (name == 'Ashar') {
      if (ashar == -1 || maghrib == -1) return false;
      return currentMinutes >= ashar && currentMinutes < maghrib;
    }

    // Maghrib until Isya → Maghrib active
    if (name == 'Maghrib') {
      if (maghrib == -1 || isya == -1) return false;
      return currentMinutes >= maghrib && currentMinutes < isya;
    }

    // After Isya → Isya active
    if (name == 'Isya') {
      if (isya == -1) return false;
      return currentMinutes >= isya;
    }

    return false;
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
