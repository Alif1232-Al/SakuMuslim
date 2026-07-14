import 'dart:async';
import 'package:alarm/alarm.dart';
import '../../core/utils/app_logger.dart';
import '../../providers/settings_provider.dart';

class PrayerNotificationService {
  PrayerNotificationService._();
  static final PrayerNotificationService instance = PrayerNotificationService._();

  // Prayer name to ID mapping (unique ID per prayer for alarm scheduling)
  static const Map<String, int> _prayerAlarmIds = {
    'Subuh': 1,
    'Dzuhur': 2,
    'Ashar': 3,
    'Maghrib': 4,
    'Isya': 5,
  };

  /// Initialize alarm service
  Future<void> init() async {
    try {
      await Alarm.init();
      AppLogger.info('Prayer notification service initialized');
    } catch (e) {
      AppLogger.error('Error initializing prayer notifications: $e');
    }
  }

  /// Schedule alarms for all enabled prayers
  /// [prayerTimes] map of prayer name to time string (HH:mm format)
  /// [settings] current settings provider for enabled/disabled state
  Future<void> schedulePrayerTimes({
    required Map<String, String> prayerTimes,
    required SettingsProvider settings,
  }) async {
    if (!settings.notificationsEnabled) {
      await cancelAll();
      return;
    }

    await cancelAll(); // Clear existing alarms first

    for (final entry in prayerTimes.entries) {
      final name = entry.key;
      final timeStr = entry.value;

      // Skip if this prayer is disabled or is "Terbit" (sunrise - not a prayer)
      if (name == 'Terbit') continue;
      if (!settings.isPrayerEnabled(name)) continue;

      try {
        final alarmTime = _parsePrayerTime(timeStr);
        if (alarmTime == null) {
          AppLogger.warning('Could not parse prayer time: $name = $timeStr');
          continue;
        }

        // Schedule alarm 2 minutes before prayer time
        final alarmDateTime = alarmTime.subtract(const Duration(minutes: 2));

        // If the alarm time has already passed today, skip it
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
  }

  /// Cancel all scheduled alarms
  Future<void> cancelAll() async {
    for (final id in _prayerAlarmIds.values) {
      await Alarm.stop(id);
    }
    AppLogger.info('All prayer alarms cancelled');
  }

  /// Stop a specific alarm by prayer name
  Future<void> stopAlarm(String prayerName) async {
    final id = _prayerAlarmIds[prayerName];
    if (id != null) {
      await Alarm.stop(id);
      AppLogger.info('Alarm stopped for $prayerName');
    }
  }

  /// Check if any alarm is currently ringing
  Future<bool> isRinging() async => Alarm.isRinging();

  /// Stream of alarm ringing state
  Stream<dynamic> get ringingStream => Alarm.ringing;

  /// Parse time string (HH:mm) to DateTime for today
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
}
