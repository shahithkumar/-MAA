import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'coloring_screen.dart';

class ArtTherapyHome extends StatelessWidget {
  const ArtTherapyHome({super.key});

  final List<Map<String, String>> _templates = const [
    {
      'name': 'Mandala 1',
      'image': 'assets/images/mandala_1.png', 
    },
    {
      'name': 'Floral',
      'image': 'assets/images/mandala_floral.png',
    },
    {
      'name': 'Geometric',
      'image': 'assets/images/mandala_geometric.png',
    },
    {
      'name': 'Abstract',
      'image': 'assets/images/mandala_abstract.png',
    },
      {
      'name': 'Zen',
      'image': 'assets/images/mandala_zen.png',
    },
    {
      'name': 'Blank Canvas',
      'image': '', // Empty string = blank
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Art Therapy',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFEBEE)], // Warm orange to pink
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color Your Calm',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 8),
                Text(
                  'Select a design to start coloring.',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppTheme.textLight,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),
                
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _templates.length,
                    itemBuilder: (context, index) {
                      final template = _templates[index];
                      final isBlank = template['image']!.isEmpty;
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ColoringScreen(
                                templateImage: template['image']!,
                                templateName: template['name']!,
                              ),
                            ),
                          );
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                  ),
                                  alignment: Alignment.center,
                                  child: isBlank
                                      ? const Icon(Icons.edit_note_rounded, size: 48, color: AppTheme.primaryColor)
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            template['image']!,
                                            fit: BoxFit.contain,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                template['name']!,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).scale();
                    },
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
