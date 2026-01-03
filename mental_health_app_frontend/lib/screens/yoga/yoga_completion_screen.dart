import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class YogaCompletionScreen extends StatefulWidget {
  final String sessionTitle;
  final int duration;

  const YogaCompletionScreen({
    super.key,
    required this.sessionTitle,
    required this.duration,
  });

  @override
  State<YogaCompletionScreen> createState() => _YogaCompletionScreenState();
}

class _YogaCompletionScreenState extends State<YogaCompletionScreen> {
  int _streak = 0;
  int _totalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  Future<void> _updateStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update streak (Logic: If last played != today, streak++)
    final lastPlayed = prefs.getString('yoga_last_played_date');
    final today = DateTime.now().toIso8601String().split('T')[0];
    int currentStreak = prefs.getInt('yoga_streak') ?? 0;

    if (lastPlayed != today) {
      currentStreak++;
      await prefs.setInt('yoga_streak', currentStreak);
      await prefs.setString('yoga_last_played_date', today);
    }
    
    // Update total minutes
    int totalMins = prefs.getInt('yoga_total_minutes') ?? 0;
    totalMins += widget.duration;
    await prefs.setInt('yoga_total_minutes', totalMins);

    setState(() {
      _streak = currentStreak;
      _totalMinutes = totalMins;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration_rounded, size: 80, color: AppTheme.accentColor),
              ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Good Job!',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              Text(
                'You completed:',
                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.sessionTitle} (${widget.duration} min)',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 40),
              // Stats Card
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.local_fire_department_rounded, '$_streak', 'Days Streak'),
                    _buildStatItem(Icons.access_time_rounded, '$_totalMinutes', 'Total Mins'),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              const Spacer(),
              GradientButton(
                text: 'Done',
                onPressed: () {
                   Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                },
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight),
        ),
      ],
    );
  }
}
