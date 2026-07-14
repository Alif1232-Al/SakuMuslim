import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'data/services/prayer_notification_service.dart';
import 'providers/quran_provider.dart';
import 'providers/settings_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/alarm/alarm_screen.dart';

 final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  await Hive.openBox('sakumuslim_user_preferences');
  await Hive.openBox('sakumuslim_bookmarks');
  final quranCacheBox = await Hive.openBox('sakumuslim_quran_cache');

  const cacheVersionKey = 'cache_version';
  const currentCacheVersion = 2;
  final storedVersion = quranCacheBox.get(cacheVersionKey, defaultValue: 0);
  if (storedVersion < currentCacheVersion) {
    await quranCacheBox.clear();
    await quranCacheBox.put(cacheVersionKey, currentCacheVersion);
    AppLogger.info('Quran cache cleared (version update)');
  }

  await AppLogger.init();
  AppLogger.info('SakuMuslim v1.0.0 starting...');

  await PrayerNotificationService.instance.init();

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  // Auto-schedule prayer alarms on startup if notifications enabled
  if (settingsProvider.notificationsEnabled) {
    PrayerNotificationService.instance.fetchAndSchedule(settings: settingsProvider);
  }

  // Listen for alarm events and navigate to AlarmScreen
  PrayerNotificationService.instance.onAlarmFired = (prayerName) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (_) => AlarmScreen(prayerName: prayerName),
          fullscreenDialog: true,
        ),
      );
    }
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: SakuMuslimApp(navigatorKey: navigatorKey),
    ),
  );
}

class SakuMuslimApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SakuMuslimApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SakuMuslim',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: context.watch<SettingsProvider>().themeMode,
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 2.0),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
