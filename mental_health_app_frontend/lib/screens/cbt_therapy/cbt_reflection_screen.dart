import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class CBTReflectionScreen extends StatelessWidget {
  final int topicId;
  final List<String> responses;
  final int sessionDuration;
  final String? aiAnalysis;

  const CBTReflectionScreen({
    super.key,
    required this.topicId,
    required this.responses,
    required this.sessionDuration,
    this.aiAnalysis,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Session Complete', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Icon(Icons.check_rounded, size: 60, color: Colors.green.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              'Well Done!',
              style: GoogleFonts.outfit(
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve taken a great step towards clarity.',
              style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat("Duration", _formatDuration(sessionDuration), Icons.timer_outlined),
                      Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
                      _buildStat("Steps", "${responses.length}/6", Icons.layers_outlined),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Key Insight
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.lightbulb_rounded, color: AppTheme.primaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Your Insight',
                        style: GoogleFonts.outfit(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    responses.isNotEmpty ? responses.last : '...',
                    style: GoogleFonts.outfit(
                      fontSize: 16, 
                      color: AppTheme.textLight,
                      height: 1.5
                    ),
                  ),
                ],
              ),
            ),

            if (aiAnalysis != null && aiAnalysis!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.psychology, color: Colors.blueAccent, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'AI Analysis',
                          style: GoogleFonts.outfit(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      aiAnalysis!,
                      style: GoogleFonts.outfit(
                        fontSize: 16, 
                        color: AppTheme.textDark,
                        height: 1.5
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
            
            GradientButton(
              text: "Back to Home",
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: AppTheme.textDark
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight),
        ),
      ],
    );
  }
}