import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';

class AlarmScreen extends StatefulWidget {
  final String prayerName;
  
  const AlarmScreen({super.key, required this.prayerName});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _autoDismissTimer;
  StreamSubscription<dynamic>? _ringingSubscription;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-dismiss after 5 minutes
    _autoDismissTimer = Timer(const Duration(minutes: 5), () {
      if (mounted) _stopAndDismiss();
    });

    // Listen for alarm stop
    _ringingSubscription = Alarm.ringing.listen((alarmSet) {
      // AlarmSet.alarms is empty when no alarms are ringing
      if (alarmSet.alarms.isEmpty && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _autoDismissTimer?.cancel();
    _ringingSubscription?.cancel();
    super.dispose();
  }

  void _stopAndDismiss() async {
    await Alarm.stopAll();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _stopAndDismiss();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A1929),
                Color(0xFF0D47A1),
                Color(0xFF1565C0),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing crescent icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.nightlight_round,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Prayer name
                Text(
                  widget.prayerName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Sudah waktunya sholat',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 48),

                // Stop button
                GestureDetector(
                  onTap: _stopAndDismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stop_circle,
                          color: Color(0xFF0D47A1),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Matikan Alarm',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
