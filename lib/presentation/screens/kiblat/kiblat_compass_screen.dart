import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_logger.dart';

class KiblatCompassScreen extends StatefulWidget {
  const KiblatCompassScreen({super.key});

  @override
  State<KiblatCompassScreen> createState() => _KiblatCompassScreenState();
}

class _KiblatCompassScreenState extends State<KiblatCompassScreen>
    with SingleTickerProviderStateMixin {
  double _heading = 0;
  double? _kiblatDirection;
  bool _hasPermission = false;
  bool _compassAvailable = false;
  String? _error;
  StreamSubscription? _compassSubscription;
  final bool _isWeb = kIsWeb;

  late AnimationController _needleController;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _needleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _needleController.dispose();
    super.dispose();
  }

  Future<void> _initCompass() async {
    try {
      if (_isWeb) {
        await _initWebMode();
        return;
      }

      var status = await Permission.locationWhenInUse.status;
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
      }

      if (status.isPermanentlyDenied) {
        setState(() {
          _error = 'Izin lokasi ditolak. Silakan aktifkan di Pengaturan aplikasi.';
          _hasPermission = false;
        });
        return;
      }

      if (!status.isGranted) {
        setState(() {
          _error = 'Izin lokasi diperlukan untuk menentukan arah kiblat.';
          _hasPermission = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _kiblatDirection = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      AppLogger.info('Qibla direction: ${_kiblatDirection?.toStringAsFixed(1)}');

      // Listen to compass events
      _compassSubscription = FlutterCompass.events?.listen(
        (event) {
          if (!mounted) return;
          final heading = event.heading;
          if (heading != null && !heading.isNaN && heading.isFinite) {
            setState(() {
              _heading = heading;
              _compassAvailable = true;
              _hasPermission = true;
            });
          }
        },
        onError: (e) {
          AppLogger.error('Compass stream error: $e');
          if (mounted) {
            setState(() {
              _compassAvailable = false;
              _hasPermission = true;
            });
          }
        },
      );

      // If no events come in 3 seconds, show fallback
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_compassAvailable && _error == null) {
          setState(() {
            _compassAvailable = false;
            _hasPermission = true;
          });
        }
      });

      setState(() {
        _hasPermission = true;
      });
    } catch (e) {
      AppLogger.error('Error initializing compass: $e');
      String message = 'Gagal menginisialisasi';
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        message = 'Gagal mendapatkan lokasi. Pastikan GPS aktif dan coba lagi.';
      } else if (e.toString().contains('location') || e.toString().contains('Location')) {
        message = 'Gagal mendapatkan lokasi. Pastikan GPS aktif.';
      } else {
        message = 'Terjadi kesalahan: ${e.toString().length > 60 ? e.toString().substring(0, 60) : e.toString()}';
      }
      setState(() {
        _error = message;
        _hasPermission = false;
      });
    }
  }

  Future<void> _initWebMode() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (!status.isGranted && !status.isPermanentlyDenied) {
      setState(() {
        _error = 'Izin lokasi diperlukan untuk menentukan arah kiblat.';
        _hasPermission = false;
      });
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _error = 'Izin lokasi ditolak. Silakan aktifkan di Pengaturan.';
        _hasPermission = false;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _kiblatDirection = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _hasPermission = true;
        _compassAvailable = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal mendapatkan lokasi di browser. Pastikan izin lokasi aktif.';
        _hasPermission = false;
      });
    }
  }

  double _calculateQiblaDirection(double latitude, double longitude) {
    final latRad = _toRadians(latitude);
    final lngRad = _toRadians(longitude);
    final kaabaLatRad = _toRadians(_kaabaLat);
    final kaabaLngRad = _toRadians(_kaabaLng);

    final dLng = kaabaLngRad - lngRad;
    final y = sin(dLng) * cos(kaabaLatRad);
    final x = cos(latRad) * sin(kaabaLatRad) -
        sin(latRad) * cos(kaabaLatRad) * cos(dLng);
    var bearing = atan2(y, x);

    bearing = _toDegrees(bearing);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
  double _toDegrees(double radians) => radians * 180 / pi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.kiblatGradient(context)),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
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
              'Arah Kiblat',
              style: AppTextStyles.h3(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _initCompass,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _buildErrorView();
    }

    if (!_hasPermission || _kiblatDirection == null) {
      return _buildLoadingView();
    }

    final kiblatAngle = _kiblatDirection!;
    final compassAngle = _heading;
    final qiblaRelativeAngle = (kiblatAngle - compassAngle) * (pi / 180);
    final compassAngleRad = compassAngle * (pi / 180);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.contentBackground(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Direction info badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${kiblatAngle.toStringAsFixed(1)}° dari Utara',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.primary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (!_compassAvailable) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kompas tidak tersedia. Putar ponsel manual menghadap ${kiblatAngle.toStringAsFixed(0)}° dari Utara.',
                        style: AppTextStyles.caption(color: AppColors.textSecondary(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Compass
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  // Compass body
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.card(context),
                          AppColors.card(context).withValues(alpha: 0.95),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),

                  // Degree markers
                  ..._buildDegreeMarkers(),

                  // Compass rose (rotates with heading)
                  Transform.rotate(
                    angle: -compassAngleRad,
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Cardinal directions
                          ..._buildCardinalMarkers(),

                          // North marker
                          Positioned(
                            top: 6,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Qibla needle (rotates relative to compass heading)
                  Transform.rotate(
                    angle: qiblaRelativeAngle,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Kaaba icon
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mosque_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        // Needle line
                        Container(
                          width: 2,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center hub
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Instruction card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.cardBorder(context),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _compassAvailable
                          ? 'Arahkan ponsel ke tanah. Putar hingga ikon masjid di atas menunjuk ke arah kiblat.'
                          : 'Putar ponsel secara manual menghadap ${kiblatAngle.toStringAsFixed(0)}° dari utara (arah Jarum Merah ke Utara).',
                      style: AppTextStyles.bodySmall(color: AppColors.textSecondary(context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.explore_off_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _error!,
              style: AppTextStyles.h4(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final settings = await Permission.locationWhenInUse.status;
                if (settings.isPermanentlyDenied) {
                  await openAppSettings();
                } else {
                  setState(() {
                    _error = null;
                    _hasPermission = false;
                  });
                  _initCompass();
                }
              },
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Buka Pengaturan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  _hasPermission = false;
                });
                _initCompass();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Menghitung arah kiblat...',
            style: AppTextStyles.bodyMedium(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDegreeMarkers() {
    return List.generate(72, (index) {
      final angle = (2 * pi * index / 72);
      final isMajor = index % 9 == 0;
      final length = isMajor ? 10.0 : 5.0;

      return Transform.rotate(
        angle: angle,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: isMajor ? 2 : 1,
            height: length,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: isMajor
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.textSecondary(context).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildCardinalMarkers() {
    final directions = [
      {'label': 'U', 'sublabel': 'Utara', 'angle': 0.0, 'color': Colors.red},
      {'label': 'T', 'sublabel': 'Timur', 'angle': pi / 2, 'color': AppColors.textSecondary(context)},
      {'label': 'S', 'sublabel': 'Selatan', 'angle': pi, 'color': AppColors.textSecondary(context)},
      {'label': 'B', 'sublabel': 'Barat', 'angle': 3 * pi / 2, 'color': AppColors.textSecondary(context)},
    ];

    return directions.map((dir) {
      final angle = dir['angle'] as double;
      final label = dir['label'] as String;
      final color = dir['color'] as Color;

      return Transform.rotate(
        angle: angle,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 22),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
