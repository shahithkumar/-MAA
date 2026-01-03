import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../data/feature_content.dart';
import 'glass_card.dart';

class FeatureInfoSheet extends StatelessWidget {
  final FeatureInfo feature;

  const FeatureInfoSheet({super.key, required this.feature});

  static void show(BuildContext context, String featureId) {
    // Look up feature, if not found use a fallback (safe fail)
    final feature = FeatureContent.features[featureId] ?? FeatureInfo(
      id: 'unknown',
      title: 'Info',
      whatIsIt: 'Information not available.',
      howToUse: '',
      benefits: '',
    );
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FeatureInfoSheet(feature: feature),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      margin: EdgeInsets.only(top: 60), // Space from top status bar
      padding: EdgeInsets.only(
        left: 24, 
        right: 24, 
        top: 24, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header with close button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  feature.title,
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.textLight),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Scrollable Content
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Main Feature Info
                   _buildFeatureSections(feature),

                   // Sub-Features Loop
                   if (feature.subFeatures != null && feature.subFeatures!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(thickness: 1, height: 1),
                      ),
                      Text(
                        "Included Features:",
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 16),
                      for (var subFeature in feature.subFeatures!) ...[
                         Container(
                           margin: const EdgeInsets.only(bottom: 32),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   Icon(Icons.subdirectory_arrow_right_rounded, color: AppTheme.primaryColor, size: 20),
                                   const SizedBox(width: 8),
                                   Text(
                                     subFeature.title,
                                     style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 12),
                               _buildFeatureSections(subFeature),
                             ],
                           ),
                         ),
                      ],
                   ],

                   const SizedBox(height: 24), // Bottom padding
                ],
              ),
            ),
          ),
          
          // Sticky Bottom Button
          Container(
            padding: const EdgeInsets.only(top: 16),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Got it!',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSections(FeatureInfo info) {
    return Column(
      children: [
        _buildSection(
            icon: Icons.help_outline_rounded,
            title: 'What is this?',
            content: info.whatIsIt,
            color: Colors.blue.shade100,
            iconColor: Colors.blue.shade700
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
          
          const SizedBox(height: 16),
          
          _buildSection(
            icon: Icons.touch_app_rounded,
            title: 'How to use it?',
            content: info.howToUse,
            color: Colors.orange.shade100,
            iconColor: Colors.orange.shade700
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: 0.1),

          const SizedBox(height: 16),
          
          _buildSection(
            icon: Icons.favorite_rounded,
            title: 'How does it help?',
            content: info.benefits,
            color: Colors.pink.shade100,
            iconColor: Colors.pink.shade700
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(begin: 0.1),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon, 
    required String title, 
    required String content,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textDark, height: 1.5),
          ),
        ],
      ),
    );
  }
}
