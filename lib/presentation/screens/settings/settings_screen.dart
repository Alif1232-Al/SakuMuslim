import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/services/prayer_notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.settingsGradient(context),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _buildContent(context),
              ),
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
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              'Pengaturan',
              style: AppTextStyles.h3(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ═══════════════════════════════════════════════
              // THEME SECTION
              // ═══════════════════════════════════════════════
              _buildSectionTitle('Tampilan'),
              _buildThemeTile(context, settings),

              const Divider(height: 24),

              // ═══════════════════════════════════════════════
              // FONT SIZE SECTION
              // ═══════════════════════════════════════════════
              _buildSectionTitle('Ukuran Font'),
              _buildFontSizeTile(context, settings),

              const Divider(height: 24),

              // ═══════════════════════════════════════════════
              // PRAYER TIMES SECTION
              // ═══════════════════════════════════════════════
              _buildSectionTitle('Waktu Sholat'),
              _buildCityTile(context, settings),
              _buildCalculationMethodTile(context, settings),

              const Divider(height: 24),

              // ═══════════════════════════════════════════════
              // NOTIFICATION SECTION
              // ═══════════════════════════════════════════════
              _buildSectionTitle('Notifikasi Sholat'),
              _buildNotificationsToggle(context, settings),
              if (settings.notificationsEnabled) ...[
                _buildPrayerNotificationTile(context, settings, 'Subuh'),
                _buildPrayerNotificationTile(context, settings, 'Dzuhur'),
                _buildPrayerNotificationTile(context, settings, 'Ashar'),
                _buildPrayerNotificationTile(context, settings, 'Maghrib'),
                _buildPrayerNotificationTile(context, settings, 'Isya'),
              ],

              const Divider(height: 24),

              // ═══════════════════════════════════════════════
              // QURAN SECTION
              // ═══════════════════════════════════════════════
              _buildSectionTitle('Al-Qur\'an'),
              _buildTranslationToggle(settings),
              _buildTransliterationToggle(settings),

              const Divider(height: 24),

              // ═══════════════════════════════════════════════
              // ABOUT SECTION
              // ═══════════════════════════════════════════════
              _buildSectionTitle('Tentang'),
              _buildAboutTile(),

              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════
              // RESET BUTTON
              // ═══════════════════════════════════════════════
              _buildResetButton(context, settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.h4(color: AppColors.primary),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, SettingsProvider settings) {
    return _buildSettingTile(
      icon: Icons.dark_mode,
      title: 'Mode Gelap',
      trailing: Switch(
        value: settings.themeMode == ThemeMode.dark,
        activeThumbColor: AppColors.primary,
        onChanged: (value) {
          settings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }

  Widget _buildFontSizeTile(BuildContext context, SettingsProvider settings) {
    return _buildSettingTile(
      icon: Icons.text_fields,
      title: 'Font Arab',
      subtitle: '${settings.fontSizeArabic.toInt()} px',
      trailing: SizedBox(
        width: 150,
        child: Slider(
          value: settings.fontSizeArabic,
          min: 20,
          max: 40,
          divisions: 10,
          activeColor: AppColors.primary,
          onChanged: (value) {
            settings.setFontSizeArabic(value);
          },
        ),
      ),
    );
  }

  Widget _buildCityTile(BuildContext context, SettingsProvider settings) {
    return _buildSettingTile(
      icon: Icons.location_on,
      title: 'Kota Default',
      subtitle: settings.defaultCity,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCityPicker(context, settings),
    );
  }

  Widget _buildCalculationMethodTile(BuildContext context, SettingsProvider settings) {
    return _buildSettingTile(
      icon: Icons.calculate,
      title: 'Metode Kalkulasi',
      subtitle: _getMethodName(settings.calculationMethod),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showMethodPicker(context, settings),
    );
  }

  Widget _buildNotificationsToggle(BuildContext context, SettingsProvider settings) {
    return _buildSettingTile(
      icon: Icons.notifications_active,
      title: 'Aktifkan Notifikasi',
      subtitle: 'Alarm 2 menit sebelum waktu sholat',
      trailing: Switch(
        value: settings.notificationsEnabled,
        activeThumbColor: AppColors.primary,
        onChanged: (value) {
          settings.setNotificationsEnabled(value);
          if (value) {
            PrayerNotificationService.instance.fetchAndSchedule(settings: settings);
          } else {
            PrayerNotificationService.instance.cancelAll();
          }
        },
      ),
    );
  }

  Widget _buildPrayerNotificationTile(
    BuildContext context,
    SettingsProvider settings,
    String prayerName,
  ) {
    return _buildSettingTile(
      icon: _getPrayerNotificationIcon(prayerName),
      title: prayerName,
      trailing: Switch(
        value: settings.isPrayerEnabled(prayerName),
        activeThumbColor: AppColors.primary,
        onChanged: (value) {
          settings.setPrayerEnabled(prayerName, value);
          if (settings.notificationsEnabled) {
            PrayerNotificationService.instance.fetchAndSchedule(settings: settings);
          }
        },
      ),
    );
  }

  IconData _getPrayerNotificationIcon(String name) {
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

  Widget _buildTranslationToggle(SettingsProvider settings) {
    return _buildSettingTile(
      icon: Icons.translate,
      title: 'Tampilkan Terjemahan',
      trailing: Switch(
        value: settings.showTranslation,
        activeThumbColor: AppColors.primary,
        onChanged: (value) {
          settings.setShowTranslation(value);
        },
      ),
    );
  }

  Widget _buildTransliterationToggle(SettingsProvider settings) {
    return _buildSettingTile(
      icon: Icons.spellcheck,
      title: 'Tampilkan Transliterasi',
      trailing: Switch(
        value: settings.showTransliteration,
        activeThumbColor: AppColors.primary,
        onChanged: (value) {
          settings.setShowTransliteration(value);
        },
      ),
    );
  }

  Widget _buildAboutTile() {
    return _buildSettingTile(
      icon: Icons.info_outline,
      title: 'Tentang SakuMuslim',
      subtitle: 'Versi 1.0.0',
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildResetButton(BuildContext context, SettingsProvider settings) {
    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Reset Pengaturan?'),
            content: const Text('Semua pengaturan akan dikembalikan ke default.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  settings.resetToDefaults();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.error),
        foregroundColor: AppColors.error,
      ),
      child: const Text('Reset ke Default'),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium()),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption())
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showCityPicker(BuildContext context, SettingsProvider settings) {
    final cities = [
      'Jakarta', 'Surabaya', 'Bandung', 'Medan',
      'Makassar', 'Yogyakarta', 'Semarang', 'Palembang',
      'Manado', 'Bali', 'Balikpapan', 'Banjarmasin',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih Kota', style: AppTextStyles.h3()),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return ListTile(
                    title: Text(city),
                    trailing: city == settings.defaultCity
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      settings.setDefaultCity(city);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMethodPicker(BuildContext context, SettingsProvider settings) {
    final methods = {
      0: 'Waktu Lokal',
      1: 'Muslim World League',
      2: 'Islamic Society of North America',
      5: 'Egyptian General Authority',
      7: 'University of Islamic Sciences, Karachi',
      20: 'Kementerian Agama RI',
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih Metode', style: AppTextStyles.h3()),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: methods.length,
                itemBuilder: (context, index) {
                  final entry = methods.entries.elementAt(index);
                  return ListTile(
                    title: Text(entry.value),
                    trailing: entry.key == settings.calculationMethod
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      settings.setCalculationMethod(entry.key);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMethodName(int method) {
    switch (method) {
      case 0: return 'Waktu Lokal';
      case 1: return 'Muslim World League';
      case 2: return 'ISNA';
      case 5: return 'Egyptian Authority';
      case 7: return 'Karachi';
      case 20: return 'Kemenag RI';
      default: return 'Kemenag RI';
    }
  }
}
