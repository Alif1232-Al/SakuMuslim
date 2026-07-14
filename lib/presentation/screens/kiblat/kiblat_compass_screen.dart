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

class _KiblatCompassScreenState extends State<KiblatCompassScreen> {
  double? _heading;
  double? _kiblatDirection;
  bool _hasPermission = false;
  String? _error;
  StreamSubscription? _compassSubscription;
  final bool _isWeb = kIsWeb;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  StreamSubscription<dynamic>? _webOrientationSubscription;

  @override
  void initState() {
    super.initState();
    _initCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _webOrientationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initCompass() async {
    try {
      var status = await Permission.locationWhenInUse.status;
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
      }

      if (status.isPermanentlyDenied) {
        setState(() {
          _error = 'Izin lokasi ditolak. Aktifkan di Pengaturan.';
          _hasPermission = false;
        });
        return;
      }

      if (!status.isGranted) {
        setState(() {
          _error = 'Izin lokasi diperlukan untuk penunjuk kiblat';
          _hasPermission = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _kiblatDirection = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      AppLogger.info('Qibla direction: $_kiblatDirection');

      if (_isWeb) {
        _initWebCompass();
      } else {
        _compassSubscription = FlutterCompass.events?.listen((event) {
          if (mounted) {
            setState(() {
              _heading = event.heading;
              _hasPermission = true;
            });
          }
        });

        setState(() {
          _hasPermission = true;
        });
      }
    } catch (e) {
      AppLogger.error('Error initializing compass: $e');
      setState(() {
        _error = 'Gagal menginisialisasi kompas: $e';
        _hasPermission = false;
      });
    }
  }

  void _initWebCompass() {
    try {
      _setupWebCompassFallback();
    } catch (e) {
      AppLogger.error('Web compass not available: $e');
      setState(() {
        _hasPermission = true;
        _heading = 0;
      });
    }
  }

  void _setupWebCompassFallback() {
    _webCompassViaJs();
  }

  Future<void> _webCompassViaJs() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && _heading == null) {
        setState(() {
          _hasPermission = true;
          _heading = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _heading = 0;
        });
      }
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
        decoration: BoxDecoration(
          gradient: AppColors.kiblatGradient(context),
        ),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.explore_off_rounded,
                size: 80,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 20),
              Text(
                _error!,
                style: AppTextStyles.h4(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                },
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: const Text('Buka Pengaturan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.card(context),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _initCompass,
                child: Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission || _heading == null || _kiblatDirection == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final compassAngle = (_heading ?? 0) * (pi / 180);
    final kiblatAngle = (_kiblatDirection ?? 0) * (pi / 180);
    final qiblaRelativeAngle = kiblatAngle - compassAngle;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.contentBackground(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_kiblatDirection!.toStringAsFixed(1)}° dari Utara',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.primary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (_isWeb) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kompas tidak tersedia di browser. Putar ponsel secara manual menghadap ${_kiblatDirection!.toStringAsFixed(0)}° dari Utara.',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card(context),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 3,
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

                  Transform.rotate(
                    angle: _isWeb ? 0 : -compassAngle,
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ..._buildCardinalMarkers(),

                          Positioned(
                            top: 8,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Transform.rotate(
                    angle: _isWeb ? kiblatAngle : qiblaRelativeAngle,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mosque_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        Container(
                          width: 2,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

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
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isWeb
                          ? 'Arahkan ponsel menghadap ${_kiblatDirection!.toStringAsFixed(0)}° dari utara untuk menghadap kiblat'
                          : 'Arahkan ponsel ke tanah dan putar hingga indikator masjid (atas) menunjuk ke arah kiblat',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.textSecondary(context),
                      ),
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

  List<Widget> _buildCardinalMarkers() {
    final directions = [
      {'label': 'N', 'angle': 0.0, 'color': Colors.red},
      {'label': 'E', 'angle': pi / 2, 'color': Colors.grey},
      {'label': 'S', 'angle': pi, 'color': Colors.grey},
      {'label': 'W', 'angle': 3 * pi / 2, 'color': Colors.grey},
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
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
