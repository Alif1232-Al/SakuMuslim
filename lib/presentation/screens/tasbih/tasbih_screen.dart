import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  int _target = AppConstants.defaultTasbihTarget;
  bool _vibrationEnabled = true;

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rippleAnimation;

  final List<Map<String, String>> _dzikirOptions = [
    {'label': 'Subhanallah', 'arabic': 'سُبْحَانَ اللَّهِ', 'meaning': 'Maha Suci Allah'},
    {'label': 'Alhamdulillah', 'arabic': 'الْحَمْدُ لِلَّهِ', 'meaning': 'Segala Puji bagi Allah'},
    {'label': 'Allahu Akbar', 'arabic': 'اللَّهُ أَكْبَرُ', 'meaning': 'Allah Maha Besar'},
    {'label': 'La ilaha illallah', 'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ', 'meaning': 'Tiada Tuhan selain Allah'},
    {'label': 'Astaghfirullah', 'arabic': 'أَسْتَغْفِرُ اللَّهَ', 'meaning': 'Aku memohon ampun Allah'},
    {'label': 'Hasbiyallah', 'arabic': 'حَسْبُنَا اللَّهُ', 'meaning': 'Cukuplah Allah bagi kami'},
  ];
  int _currentDzikirIndex = 0;

  final List<int> _sessionHistory = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _count++;
    });

    if (_vibrationEnabled) {
      if (_count % _target == 0) {
        HapticFeedback.heavyImpact();
      } else if (_count % 10 == 0) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    _pulseController.forward().then((_) => _pulseController.reverse());
    _glowController.forward(from: 0.0);
    _rippleController.forward(from: 0.0).then((_) {
      _rippleController.reset();
    });

    if (_count >= _target) {
      _sessionHistory.add(_count);
      _showTargetReachedDialog();
    }

    AppLogger.debug('Tasbih count: $_count');
  }

  void _reset() {
    if (_count > 0) {
      _sessionHistory.add(_count);
    }
    setState(() {
      _count = 0;
    });
    AppLogger.info('Tasbih reset. Sessions: $_sessionHistory');
  }

  void _showTargetReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.card(context),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Masya Allah!',
              style: AppTextStyles.h3(color: AppColors.textPrimary(context)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Anda telah menyelesaikan',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 4),
            Text(
              '$_target kali',
              style: AppTextStyles.h3(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              _dzikirOptions[_currentDzikirIndex]['label']!,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary(context)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: Text('Ulangi', style: AppTextStyles.buttonMedium(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dzikir = _dzikirOptions[_currentDzikirIndex];
    final progress = _count / _target;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.tasbihGradient(context)),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
              _buildDzikirSelector(),
              Expanded(
                child: _buildCounterDisplay(dzikir, progress),
              ),
              _buildControls(),
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
              'Tasbih Digital',
              style: AppTextStyles.h3(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _vibrationEnabled = !_vibrationEnabled);
            },
            icon: Icon(
              _vibrationEnabled ? Icons.vibration : Icons.vibration_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDzikirSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _dzikirOptions.length,
        itemBuilder: (context, index) {
          final dzikir = _dzikirOptions[index];
          final isSelected = index == _currentDzikirIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentDzikirIndex = index;
                _count = 0;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGold
                      : Colors.white.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dzikir['arabic']!,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: isSelected ? const Color(0xFF5D4037) : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dzikir['label']!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.accentGold : Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    dzikir['meaning']!,
                    style: AppTextStyles.caption(
                      color: isSelected
                          ? const Color(0xFF8D6E63)
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCounterDisplay(Map<String, String> dzikir, double progress) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dzikir['arabic']!,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              dzikir['meaning']!,
              style: AppTextStyles.bodyMedium(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _increment,
              child: AnimatedBuilder(
                listenable: Listenable.merge([_pulseAnimation, _glowAnimation, _rippleAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: CustomPaint(
                      size: const Size(240, 240),
                      painter: _TasbihCirclePainter(
                        progress: progress,
                        glowIntensity: _glowAnimation.value,
                        rippleProgress: _rippleAnimation.value,
                        count: _count,
                        target: _target,
                      ),
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.95),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withValues(alpha: 0.2 + _glowAnimation.value * 0.3),
                              blurRadius: 40 + _glowAnimation.value * 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_count',
                              style: AppTextStyles.tasbihCounter(
                                size: 72,
                                color: const Color(0xFF5D4037),
                              ),
                            ),
                            Text(
                              '/ $_target',
                              style: AppTextStyles.bodyMedium(
                                color: const Color(0xFF8D6E63),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${((progress) * 100).toInt()}%',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFC6A054),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                  minHeight: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.refresh_rounded,
                  label: 'Reset',
                  onTap: _reset,
                ),
                _buildControlButton(
                  icon: Icons.flag_rounded,
                  label: 'Target',
                  onTap: _showTargetDialog,
                  isActive: true,
                ),
                _buildControlButton(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  onTap: _showHistoryDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.card(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.cardBorder(context),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog() {
    final targets = [33, 99, 100, 500, 1000];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.card(context),
        title: Text(
          'Atur Target',
          style: AppTextStyles.h3(color: AppColors.textPrimary(context)),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: targets.map((target) {
            final isSelected = target == _target;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _target = target;
                  _count = 0;
                });
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBorder(context),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                    else
                      Icon(Icons.circle_outlined, color: AppColors.textSecondary(context), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '$target kali',
                      style: AppTextStyles.bodyMedium(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary(context),
                        weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.card(context),
        title: Text(
          'Riwayat Sesi',
          style: AppTextStyles.h3(color: AppColors.textPrimary(context)),
          textAlign: TextAlign.center,
        ),
        content: _sessionHistory.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 48,
                      color: AppColors.textSecondary(context).withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada riwayat',
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sessionHistory.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = _sessionHistory.length - 1 - index;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_sessionHistory.length - reversedIndex}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dzikirOptions[_currentDzikirIndex]['label']!,
                              style: AppTextStyles.bodyMedium(color: AppColors.textPrimary(context)),
                            ),
                          ),
                          Text(
                            '${_sessionHistory[reversedIndex]}',
                            style: AppTextStyles.h4(color: AppColors.primary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        actions: [
          if (_sessionHistory.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _sessionHistory.clear());
                Navigator.pop(context);
              },
              child: Text('Hapus Semua', style: AppTextStyles.buttonMedium(color: AppColors.error)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTextStyles.buttonMedium(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _TasbihCirclePainter extends CustomPainter {
  final double progress;
  final double glowIntensity;
  final double rippleProgress;
  final int count;
  final int target;

  _TasbihCirclePainter({
    required this.progress,
    required this.glowIntensity,
    required this.rippleProgress,
    required this.count,
    required this.target,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final beadRadius = 6.0;

    // Outer decorative ring
    final outerRingPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 8, outerRingPaint);

    // Beads around the circle
    final totalBeads = target.clamp(10, 99);
    final beadCount = min(totalBeads, count);
    final beadPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < totalBeads; i++) {
      final angle = (2 * pi * i / totalBeads) - (pi / 2);
      final x = center.dx + (radius - 20) * cos(angle);
      final y = center.dy + (radius - 20) * sin(angle);

      if (i < beadCount) {
        beadPaint.color = const Color(0xFFC6A054);
      } else {
        beadPaint.color = const Color(0xFFD7CCC8).withValues(alpha: 0.5);
      }

      canvas.drawCircle(Offset(x, y), beadRadius, beadPaint);

      if (i < beadCount) {
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(x - 1.5, y - 1.5),
          2,
          highlightPaint,
        );
      }
    }

    // Ripple effect
    if (rippleProgress > 0 && rippleProgress < 1) {
      final ripplePaint = Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.3 * (1 - rippleProgress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, radius * (0.3 + rippleProgress * 0.4), ripplePaint);
    }

    // Glow ring when active
    if (glowIntensity > 0) {
      final glowPaint = Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.15 * glowIntensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, radius - 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TasbihCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.rippleProgress != rippleProgress ||
        oldDelegate.count != count;
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
