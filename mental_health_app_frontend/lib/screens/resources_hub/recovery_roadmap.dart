import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class RecoveryRoadmapScreen extends StatefulWidget {
  final int disorderId;

  const RecoveryRoadmapScreen({Key? key, required this.disorderId}) : super(key: key);

  @override
  _RecoveryRoadmapScreenState createState() => _RecoveryRoadmapScreenState();
}

class _RecoveryRoadmapScreenState extends State<RecoveryRoadmapScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? roadmap;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _apiService.getRecoveryRoadmap(widget.disorderId);
      if (mounted) {
        setState(() {
          roadmap = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unable to load roadmap. Please check your connection or try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 3,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorColor.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(
                errorMessage!,
                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadRoadmap,
                child: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (roadmap == null || roadmap!['steps'] == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 80, color: AppTheme.textLight),
              const SizedBox(height: 20),
              Text(
                'No roadmap available',
                style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textDark),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor.withOpacity(0.15), AppTheme.accentColor.withOpacity(0.15)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline_rounded, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Your Journey',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Follow these steps to build a stronger, healthier you. Take it one day at a time. 🌟',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppTheme.textDark,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms),
        
        // Disorder Roadmap Image
        if (roadmap!['roadmap_image'] != null) ...[
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                roadmap!['roadmap_image'],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[100],
                    child: Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey[400])),
                  );
                },
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],

        const SizedBox(height: 32),
        // Steps List
        ...List.generate(
          roadmap!['steps']?.length ?? 0,
          (index) {
            final step = roadmap!['steps'][index] as Map<String, dynamic>;
            final title = step['title'] ?? 'Step ${index + 1}';
            final description = step['description'] ?? '';
            final image = step['image'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Number Circle
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  color: AppTheme.textLight,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Step Image
                    if (image != null) ...[
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          image,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                              height: 150,
                              color: Colors.grey[100],
                              child: Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey[300])),
                              );
                            },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (300 + index * 100).ms).slideX(begin: 0.1);
          },
        ),
        const SizedBox(height: 32),
      ],
    ),
  );
  }
}