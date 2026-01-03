import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)], // Lavender to Pink
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.6),
                boxShadow: [
                   BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 0,
                  )
                ]
              ),
              child: const Icon(Icons.handshake_rounded, size: 80, color: AppTheme.accentColor),
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              'Here for You',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Access tools, therapy, and support anytime, anywhere.',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  color: AppTheme.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 500.ms),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: GradientButton(
                text: "Get Started",
                onPressed: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => LoginScreen())
                  );
                },
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}