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
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _target = AppConstants.defaultTasbihTarget;
  bool _vibrationEnabled = true;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<String> _dzikirOptions = [
    'Subhanallah',
    'Alhamdulillah',
    'Allahu Akbar',
    'La ilaha illallah',
    'Astaghfirullah',
    'Hasbiyallah',
  ];
  String _currentDzikir = 'Subhanallah';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _count++;
    });

    // Haptic feedback
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    // Animation
    _controller.forward().then((_) {
      _controller.reverse();
    });

    // Check if target reached
    if (_count >= _target) {
      _showTargetReachedDialog();
    }

    AppLogger.debug('Tasbih count: $_count');
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
    AppLogger.info('Tasbih reset');
  }

  void _showTargetReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Masya Allah!',
              style: AppTextStyles.h3(color: AppColors.textPrimary(context)),
            ),
          ],
        ),
        content: Text(
          'Anda telah menyelesaikan $_target kali $_currentDzikir',
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary(context)),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: Text(
              'Ulangi',
              style: AppTextStyles.buttonMedium(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.tasbihGradient(context),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Dzikir Selector
              _buildDzikirSelector(),

              // Counter Display
              Expanded(
                child: _buildCounterDisplay(),
              ),

              // Controls
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
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
              setState(() {
                _vibrationEnabled = !_vibrationEnabled;
              });
            },
            icon: Icon(
              _vibrationEnabled
                  ? Icons.vibration
                  : Icons.vibration_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDzikirSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dzikirOptions.length,
        itemBuilder: (context, index) {
          final dzikir = _dzikirOptions[index];
          final isSelected = dzikir == _currentDzikir;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentDzikir = dzikir;
                _count = 0;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  dzikir,
                  style: AppTextStyles.bodyMedium(
                    color: isSelected
                        ? const Color(0xFFC6A054)
                        : Colors.white,
                    weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCounterDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Current dzikir
          Text(
            _currentDzikir,
            style: AppTextStyles.arabic(
              size: 32,
              color: const Color(0xFF5D4037),
            ),
          ),

          const SizedBox(height: 32),

          // Counter circle
          GestureDetector(
            onTap: _increment,
            child: AnimatedBuilder(
              listenable: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC6A054).withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_count',
                      style: AppTextStyles.tasbihCounter(
                        size: 64,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                    Text(
                      '/ $_target',
                      style: AppTextStyles.bodyMedium(
              color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Progress indicator
          SizedBox(
            width: 200,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _count / _target,
                  backgroundColor: const Color(0xFFE0C882).withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFC6A054),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${((_count / _target) * 100).toInt()}%',
                  style: AppTextStyles.caption(
                    color: const Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
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
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Reset button
            _buildControlButton(
              icon: Icons.refresh,
              label: 'Reset',
              onTap: _reset,
              color: AppColors.textSecondaryLight,
            ),

            // Tap area indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ketuk untuk menghitung',
                    style: AppTextStyles.caption(color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // Target button
            _buildControlButton(
              icon: Icons.flag,
              label: 'Target',
              onTap: _showTargetDialog,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption(color: color),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Atur Target',
          style: AppTextStyles.h3(color: AppColors.textPrimary(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [33, 99, 100, 500, 1000].map((target) {
            return ListTile(
              title: Text('$target kali'),
              leading: Radio<int>(
                value: target,
                groupValue: _target,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _target = value!;
                    _count = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                setState(() {
                  _target = target;
                  _count = 0;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Simple AnimatedBuilder equivalent
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
