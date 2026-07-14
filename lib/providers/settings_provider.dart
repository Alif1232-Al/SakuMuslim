import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/constants/storage_keys.dart';
import '../core/utils/app_logger.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _box;

  // ═══════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  double _fontSizeArabic = StorageKeys.defaultFontSizeArabic;
  double get fontSizeArabic => _fontSizeArabic;

  double _fontSizeTranslation = StorageKeys.defaultFontSizeTranslation;
  double get fontSizeTranslation => _fontSizeTranslation;

  String _defaultCity = StorageKeys.defaultCity;
  String get defaultCity => _defaultCity;

  String _defaultCountry = StorageKeys.defaultCountry;
  String get defaultCountry => _defaultCountry;

  int _calculationMethod = StorageKeys.defaultCalculationMethod;
  int get calculationMethod => _calculationMethod;

  bool _showTranslation = true;
  bool get showTranslation => _showTranslation;

  bool _showTransliteration = false;
  bool get showTransliteration => _showTransliteration;

  // Notification settings
  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  Map<String, bool> _perPrayerEnabled = {
    'Subuh': true,
    'Dzuhur': true,
    'Ashar': true,
    'Maghrib': true,
    'Isya': true,
  };
  Map<String, bool> get perPrayerEnabled => Map.unmodifiable(_perPrayerEnabled);

  // ═══════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════

  Future<void> init() async {
    try {
      _box = await Hive.openBox(StorageKeys.boxUserPreferences);
      _loadSettings();
      AppLogger.info('Settings provider initialized');
    } catch (e) {
      AppLogger.error('Error initializing settings: $e');
    }
  }

  void _loadSettings() {
    final themeModeIndex = _box.get(StorageKeys.keyThemeMode, defaultValue: 0);
    if (themeModeIndex is int && themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
    } else {
      _themeMode = ThemeMode.system;
    }
    _fontSizeArabic = _box.get(StorageKeys.keyFontSizeArabic, defaultValue: StorageKeys.defaultFontSizeArabic);
    _fontSizeTranslation = _box.get(StorageKeys.keyFontSizeTranslation, defaultValue: StorageKeys.defaultFontSizeTranslation);
    _defaultCity = _box.get(StorageKeys.keyDefaultCity, defaultValue: StorageKeys.defaultCity);
    _defaultCountry = _box.get(StorageKeys.keyDefaultCountry, defaultValue: StorageKeys.defaultCountry);
    _calculationMethod = _box.get(StorageKeys.keyCalculationMethod, defaultValue: StorageKeys.defaultCalculationMethod);
    _showTranslation = _box.get(StorageKeys.keyShowTranslation, defaultValue: true);
    _showTransliteration = _box.get(StorageKeys.keyShowTransliteration, defaultValue: false);

    _notificationsEnabled = _box.get(StorageKeys.keyNotificationsEnabled, defaultValue: false);
    final perPrayerMap = _box.get(StorageKeys.keyPerPrayerEnabled);
    if (perPrayerMap != null && perPrayerMap is Map) {
      _perPrayerEnabled = Map<String, bool>.from(perPrayerMap);
    }

    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════
  // SETTERS
  // ═══════════════════════════════════════════════════════

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _box.put(StorageKeys.keyThemeMode, mode.index);
    notifyListeners();
    AppLogger.info('Theme mode changed: $mode');
  }

  Future<void> setFontSizeArabic(double size) async {
    _fontSizeArabic = size;
    await _box.put(StorageKeys.keyFontSizeArabic, size);
    notifyListeners();
  }

  Future<void> setFontSizeTranslation(double size) async {
    _fontSizeTranslation = size;
    await _box.put(StorageKeys.keyFontSizeTranslation, size);
    notifyListeners();
  }

  Future<void> setDefaultCity(String city) async {
    _defaultCity = city;
    await _box.put(StorageKeys.keyDefaultCity, city);
    notifyListeners();
    AppLogger.info('Default city changed: $city');
  }

  Future<void> setDefaultCountry(String country) async {
    _defaultCountry = country;
    await _box.put(StorageKeys.keyDefaultCountry, country);
    notifyListeners();
  }

  Future<void> setCalculationMethod(int method) async {
    _calculationMethod = method;
    await _box.put(StorageKeys.keyCalculationMethod, method);
    notifyListeners();
  }

  Future<void> setShowTranslation(bool show) async {
    _showTranslation = show;
    await _box.put(StorageKeys.keyShowTranslation, show);
    notifyListeners();
  }

  Future<void> setShowTransliteration(bool show) async {
    _showTransliteration = show;
    await _box.put(StorageKeys.keyShowTransliteration, show);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _box.put(StorageKeys.keyNotificationsEnabled, enabled);
    notifyListeners();
    AppLogger.info('Notifications ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> setPrayerEnabled(String prayerName, bool enabled) async {
    _perPrayerEnabled[prayerName] = enabled;
    await _box.put(StorageKeys.keyPerPrayerEnabled, _perPrayerEnabled);
    notifyListeners();
  }

  bool isPrayerEnabled(String prayerName) {
    return _perPrayerEnabled[prayerName] ?? true;
  }

  // ═══════════════════════════════════════════════════════
  // RESET
  // ═══════════════════════════════════════════════════════

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _fontSizeArabic = StorageKeys.defaultFontSizeArabic;
    _fontSizeTranslation = StorageKeys.defaultFontSizeTranslation;
    _defaultCity = StorageKeys.defaultCity;
    _defaultCountry = StorageKeys.defaultCountry;
    _calculationMethod = StorageKeys.defaultCalculationMethod;
    _showTranslation = true;
    _showTransliteration = false;
    _notificationsEnabled = false;
    _perPrayerEnabled = {
      'Subuh': true,
      'Dzuhur': true,
      'Ashar': true,
      'Maghrib': true,
      'Isya': true,
    };

    await _box.putAll({
      StorageKeys.keyThemeMode: 0,
      StorageKeys.keyFontSizeArabic: StorageKeys.defaultFontSizeArabic,
      StorageKeys.keyFontSizeTranslation: StorageKeys.defaultFontSizeTranslation,
      StorageKeys.keyDefaultCity: StorageKeys.defaultCity,
      StorageKeys.keyDefaultCountry: StorageKeys.defaultCountry,
      StorageKeys.keyCalculationMethod: StorageKeys.defaultCalculationMethod,
      StorageKeys.keyShowTranslation: true,
      StorageKeys.keyShowTransliteration: false,
      StorageKeys.keyNotificationsEnabled: false,
      StorageKeys.keyPerPrayerEnabled: _perPrayerEnabled,
    });
    notifyListeners();
    AppLogger.info('Settings reset to defaults');
  }
}
