import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/feature_info_sheet.dart';

// Screens
import 'music_mood_screen.dart';
import 'drawing_choice_screen.dart';
import '../cbt_therapy/cbt_topics_screen.dart';
import '../yoga/yoga_home_screen.dart';

class TherapyHomeScreen extends StatelessWidget {
  const TherapyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Therapy Room',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textDark),
            onPressed: () => FeatureInfoSheet.show(context, 'therapy_room'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Intro Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Heal with Creativity",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Explore music, art, and movement to express what words cannot.",
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Features Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildTherapyOption(
                  context,
                  title: "Music",
                  subtitle: "Listen & Feel",
                  icon: Icons.music_note_rounded,
                  color: Colors.purpleAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicMoodScreen())),
                ),
                _buildTherapyOption(
                  context,
                  title: "Drawing",
                  subtitle: "Art Therapy",
                  icon: Icons.brush_rounded,
                  color: Colors.orangeAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DrawingChoiceScreen())),
                ),
                _buildTherapyOption(
                  context,
                  title: "CBT",
                  subtitle: "Cognitive Tools",
                  icon: Icons.psychology_rounded,
                  color: Colors.tealAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CBTTopicsScreen())),
                ),
                _buildTherapyOption(
                  context,
                  title: "Yoga",
                  subtitle: "Body & Mind",
                  icon: Icons.self_improvement_rounded,
                  color: Colors.blueAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YogaHomeContent())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTherapyOption(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
