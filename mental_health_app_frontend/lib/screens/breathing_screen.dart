import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  String _instruction = "Find a comfortable position";
  String _phase = "READY"; // READY, SETTINGS, INHALE, HOLD, EXHALE, COMPLETE
  int _secondsRemaining = 0;
  int _totalDurationMinutes = 1;
  int _sessionSecondsLeft = 0;
  Timer? _timer;
  Timer? _sessionTimer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _phase = "SETTINGS";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sessionTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _sessionSecondsLeft = _totalDurationMinutes * 60;
      _phase = "READY";
    });
    
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sessionSecondsLeft > 0) {
        if (mounted) setState(() => _sessionSecondsLeft--);
      } else {
        _endSession();
      }
    });

    _inhale();
  }

  void _endSession() {
    _timer?.cancel();
    _sessionTimer?.cancel();
    _animationController.stop();
    if (mounted) {
      setState(() {
        _phase = "COMPLETE";
        _instruction = "Take a moment to notice how you feel.";
      });
    }
    HapticFeedback.heavyImpact();
  }

  void _inhale() {
    if (!mounted || _phase == "COMPLETE") return;
    setState(() {
      _instruction = "Breathe in slowly through your nose...";
      _phase = "INHALE";
      _secondsRemaining = 4;
    });
    _animationController.duration = const Duration(seconds: 4);
    _animationController.forward(from: 0.0);
    HapticFeedback.lightImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _hold();
      }
    });
  }

  void _hold() {
    if (!mounted || _phase == "COMPLETE") return;
    setState(() {
      _instruction = "Hold your breath...";
      _phase = "HOLD";
      _secondsRemaining = 7;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _exhale();
      }
    });
  }

  void _exhale() {
    if (!mounted || _phase == "COMPLETE") return;
    setState(() {
      _instruction = "Exhale slowly through your mouth...";
      _phase = "EXHALE";
      _secondsRemaining = 8;
    });
    _animationController.duration = const Duration(seconds: 8);
    _animationController.reverse(from: 1.0);
    HapticFeedback.mediumImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _inhale();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('4-7-8 Breathing', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFF3E5F5)], // Soft Cyan to Soft Lavender
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _phase == "SETTINGS" 
              ? _buildSettings() 
              : _phase == "COMPLETE" 
                ? _buildComplete()
                : _buildExercise(),
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.spa_rounded, size: 60, color: AppTheme.primaryColor)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(duration: 2500.ms, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
          ),
          const SizedBox(height: 32),
          Text(
            "Mindful Breathing",
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 12),
          Text(
            "Choose a duration for your 4-7-8 breathing session.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
          ),
          const SizedBox(height: 48),
          _buildDurationOptions(),
          const SizedBox(height: 60),
          GradientButton(
            text: "Start Session",
            onPressed: _startSession,
            icon: Icons.play_arrow_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [1, 2, 5].map((mins) {
        bool isSelected = _totalDurationMinutes == mins;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _totalDurationMinutes = mins);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected ? [
                BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
              ] : [],
              border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.white),
            ),
            child: Text(
              "$mins min",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExercise() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _phase,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppTheme.primaryColor,
          ),
        ).animate(key: ValueKey(_phase)).fadeIn().scale(),
        const SizedBox(height: 16),
        Text(
          "$_secondsRemaining",
          style: GoogleFonts.outfit(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 48),
        
        // Animated Breathing Circle
        Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double val = _animationController.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.05 + (0.1 * val)),
                    ),
                  ),
                  // Animated Ring
                  Container(
                    width: 220 + (80 * val),
                    height: 220 + (80 * val),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2 + (0.3 * val)),
                        width: 2,
                      ),
                    ),
                  ),
                  // Main Circle
                  Container(
                    width: 160 + (100 * val),
                    height: 160 + (100 * val),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          AppTheme.primaryColor.withOpacity(0.3 + (0.4 * val)),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1 + (0.2 * val)),
                          blurRadius: 40 * val,
                          spreadRadius: 10 * val,
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _instruction,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ).animate(key: ValueKey(_instruction)).fadeIn().slideY(begin: 0.1, end: 0),
        ),
        const SizedBox(height: 48),
        
        // Session Progress
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "${(_sessionSecondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_sessionSecondsLeft % 60).toString().padLeft(2, '0')} remaining",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textLight),
          ),
        ),
      ],
    );
  }

  Widget _buildComplete() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppTheme.successColor.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))
              ]
            ),
            child: const Icon(Icons.check_rounded, size: 80, color: AppTheme.successColor),
          ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
          const SizedBox(height: 32),
          Text(
            "Session Complete",
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          Text(
            "You have successfully completed your breathing session. Feel the calm within you.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight, height: 1.5),
          ),
          const SizedBox(height: 60),
          GradientButton(
            text: "Finish",
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _phase = "SETTINGS"),
            child: Text("Start Again", style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
