import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/app_logger.dart';
import '../../providers/settings_provider.dart';

class PrayerNotificationService {
  PrayerNotificationService._();
  static final PrayerNotificationService instance = PrayerNotificationService._();

  static const Map<String, int> _prayerAlarmIds = {
    'Subuh': 1,
    'Dzuhur': 2,
    'Ashar': 3,
    'Maghrib': 4,
    'Isya': 5,
  };

  Timer? _dailyRescheduleTimer;
  StreamSubscription<dynamic>? _ringingSubscription;
  Function(String prayerName)? onAlarmFired;

  Future<void> init() async {
    try {
      await Alarm.init();
      _startDailyReschedule();
      _listenAlarmRinging();
      AppLogger.info('Prayer notification service initialized');
    } catch (e) {
      AppLogger.error('Error initializing prayer notifications: $e');
    }
  }

  void _listenAlarmRinging() {
    _ringingSubscription?.cancel();
    _ringingSubscription = Alarm.ringing.listen((alarmSet) {
      if (alarmSet.alarms.isNotEmpty) {
        final alarmId = alarmSet.alarms.first.id;
        final prayerName = _prayerAlarmIds.entries
            .where((e) => e.value == alarmId)
            .map((e) => e.key)
            .firstOrNull;
        if (prayerName != null) {
          AppLogger.info('Alarm fired for $prayerName');
          onAlarmFired?.call(prayerName);
        }
      }
    });
  }

  void _startDailyReschedule() {
    _dailyRescheduleTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 5, 0);
    final duration = tomorrow.difference(now);
    _dailyRescheduleTimer = Timer(duration, () {
      AppLogger.info('Daily prayer alarm reschedule triggered');
      fetchAndSchedule();
    });
  }

  Future<void> fetchAndSchedule({SettingsProvider? settings}) async {
    try {
      final settingsProvider = settings;
      if (settingsProvider != null && !settingsProvider.notificationsEnabled) {
        return;
      }

      final city = settingsProvider?.defaultCity ?? 'Jakarta';
      final method = settingsProvider?.calculationMethod ?? 20;

      final dio = Dio();
      String url;

      if (settingsProvider != null &&
          settingsProvider.useGpsLocation &&
          settingsProvider.gpsLatitude != 0 &&
          settingsProvider.gpsLongitude != 0) {
        url = '${ApiEndpoints.prayerTimeBaseUrl}/timings'
            '?latitude=${settingsProvider.gpsLatitude}'
            '&longitude=${settingsProvider.gpsLongitude}'
            '&method=$method';
      } else {
        url = '${ApiEndpoints.prayerTimeBaseUrl}/timingsByCity'
            '?city=${Uri.encodeComponent(city)}&country=Indonesia&method=$method';
      }

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final timings = response.data['data']['timings'];
        final prayerTimes = {
          'Subuh': _formatTime(timings['Fajr']),
          'Terbit': _formatTime(timings['Sunrise']),
          'Dzuhur': _formatTime(timings['Dhuhr']),
          'Ashar': _formatTime(timings['Asr']),
          'Maghrib': _formatTime(timings['Maghrib']),
          'Isya': _formatTime(timings['Isha']),
        };

        if (settingsProvider != null) {
          await schedulePrayerTimes(
            prayerTimes: prayerTimes,
            settings: settingsProvider,
          );
        }

        AppLogger.info('Prayer alarms auto-scheduled for $city');
      }
    } catch (e) {
      AppLogger.error('Error auto-scheduling prayer alarms: $e');
    }
  }

  String _formatTime(String time) {
    return time.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();
  }

  Future<void> schedulePrayerTimes({
    required Map<String, String> prayerTimes,
    required SettingsProvider settings,
  }) async {
    if (!settings.notificationsEnabled) {
      await cancelAll();
      return;
    }

    await cancelAll();

    for (final entry in prayerTimes.entries) {
      final name = entry.key;
      final timeStr = entry.value;

      if (name == 'Terbit') continue;
      if (!settings.isPrayerEnabled(name)) continue;

      try {
        final alarmTime = _parsePrayerTime(timeStr);
        if (alarmTime == null) {
          AppLogger.warning('Could not parse prayer time: $name = $timeStr');
          continue;
        }

        final alarmDateTime = alarmTime.subtract(const Duration(minutes: 2));

        if (alarmDateTime.isBefore(DateTime.now())) {
          AppLogger.info('Alarm for $name already passed, skipping');
          continue;
        }

        final alarmId = _prayerAlarmIds[name];
        if (alarmId == null) continue;

        final alarmSettings = AlarmSettings(
          id: alarmId,
          dateTime: alarmDateTime,
          assetAudioPath: 'assets/audio/adhan.mp3',
          loopAudio: true,
          vibrate: true,
          androidFullScreenIntent: true,
          volumeSettings: VolumeSettings.fade(
            volume: 1.0,
            fadeDuration: const Duration(seconds: 5),
          ),
          notificationSettings: NotificationSettings(
            title: '🕌 Waktu Sholat',
            body: '$name dalam 2 menit',
            stopButton: 'Matikan',
          ),
        );

        await Alarm.set(alarmSettings: alarmSettings);
        AppLogger.info('Alarm scheduled for $name at $alarmDateTime');
      } catch (e) {
        AppLogger.error('Error scheduling alarm for $name: $e');
      }
    }

    _startDailyReschedule();
  }

  Future<void> cancelAll() async {
    for (final id in _prayerAlarmIds.values) {
      await Alarm.stop(id);
    }
    AppLogger.info('All prayer alarms cancelled');
  }

  Future<void> stopAlarm(String prayerName) async {
    final id = _prayerAlarmIds[prayerName];
    if (id != null) {
      await Alarm.stop(id);
      AppLogger.info('Alarm stopped for $prayerName');
    }
  }

  Future<bool> isRinging() async => Alarm.isRinging();

  Stream<dynamic> get ringingStream => Alarm.ringing;

  DateTime? _parsePrayerTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _dailyRescheduleTimer?.cancel();
    _ringingSubscription?.cancel();
  }
}
