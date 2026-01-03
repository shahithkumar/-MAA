import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'meditation_detail_screen.dart';
import 'yoga_detail_screen.dart';
import 'yoga/yoga_home_screen.dart';
import '../widgets/feature_info_sheet.dart';

class MeditationYogaScreen extends StatefulWidget {
  const MeditationYogaScreen({super.key});

  @override
  _MeditationYogaScreenState createState() => _MeditationYogaScreenState();
}

class _MeditationYogaScreenState extends State<MeditationYogaScreen> {
  bool _isMeditation = true;
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getSessions() async {
    if (_isMeditation) {
      return await _apiService.getMeditationSessions();
    } else {
      return await _apiService.getYogaSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meditation & Yoga',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textDark),
            onPressed: () => FeatureInfoSheet.show(context, 'meditation_yoga'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildToggleBtn('Meditation', Icons.self_improvement_rounded, _isMeditation)),
                    Expanded(child: _buildToggleBtn('Yoga', Icons.spa_rounded, !_isMeditation)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
            
            // Sessions List
            Expanded(
              child: _isMeditation
                  ? _buildMeditationList() 
                  : const YogaHomeContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          setState(() => _isMeditation = label == 'Meditation');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isActive ? Colors.white : AppTheme.textLight, 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationList() {
    return FutureBuilder(
      future: getSessions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
             return Center(child: Text("No sessions available yet", style: GoogleFonts.outfit(color: AppTheme.textLight)));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
               var session = sessions[index];
               final duration = '${session['duration']} min';
               
               return Padding(
                 padding: const EdgeInsets.only(bottom: 16),
                 child: Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(24),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.04),
                         blurRadius: 15,
                         offset: const Offset(0, 5),
                       )
                     ],
                   ),
                   child: InkWell(
                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MeditationDetailScreen(id: session['id']))),
                     child: Row(
                       children: [
                         Container(
                           height: 64,
                           width: 64,
                           decoration: BoxDecoration(
                             color: AppTheme.primaryColor.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Center(
                             child: Text(
                               session['emoji'] ?? '🧘',
                               style: const TextStyle(fontSize: 30),
                             ),
                           ),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 session['title'] ?? 'Untitled', 
                                 style: GoogleFonts.outfit(
                                   fontSize: 18, 
                                   fontWeight: FontWeight.bold, 
                                   color: AppTheme.textDark
                                 )
                               ),
                               const SizedBox(height: 6),
                               Row(
                                 children: [
                                   Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textLight),
                                   const SizedBox(width: 4),
                                   Text(
                                     duration, 
                                     style: GoogleFonts.outfit(
                                       fontSize: 13,
                                       fontWeight: FontWeight.w500,
                                       color: AppTheme.textLight
                                     )
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                         Container(
                           padding: const EdgeInsets.all(10),
                           decoration: BoxDecoration(
                             color: AppTheme.primaryColor,
                             shape: BoxShape.circle,
                             boxShadow: [
                               BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                             ]
                           ),
                           child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                         ),
                       ],
                     ),
                   ),
                 ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
               );
            },
          );
        } else if (snapshot.hasError) {
           return Center(child: Text("Error: ${snapshot.error}", style: GoogleFonts.outfit(color: AppTheme.errorColor)));
        }
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
      },
    );
  }
}