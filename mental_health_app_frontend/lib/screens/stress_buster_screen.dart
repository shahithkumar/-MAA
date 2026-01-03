import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';
import 'grounding_screen.dart';
import 'breathing_screen.dart';
import '../widgets/feature_info_sheet.dart';

class StressBusterScreen extends StatefulWidget {
  const StressBusterScreen({super.key});

  @override
  State<StressBusterScreen> createState() => _StressBusterScreenState();
}

class _StressBusterScreenState extends State<StressBusterScreen> with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  final _tts = FlutterTts();
  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes
  bool _isPaused = false;
  String _noteText = '';
  String _sessionType = 'text';
  bool _sessionCompleted = false;
  String? _aiFeedback;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      }
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _endSession();
      }
    });
  }

  void _triggerHaptic() {
    HapticFeedback.mediumImpact();
  }

  void _pauseTimer() {
    _triggerHaptic();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    _triggerHaptic();
    setState(() {
      _isPaused = false;
    });
  }

  void _restartTimer() {
    _triggerHaptic();
    setState(() {
      _secondsRemaining = 120; // Reset to 2 minutes
      _isPaused = false;
    });
    _startTimer();
  }

  void _cancelSession() {
    _triggerHaptic();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Session?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        content: Text('Are you sure you want to cancel without saving?', style: GoogleFonts.outfit(color: AppTheme.textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: GoogleFonts.outfit(color: AppTheme.primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Close Screen
            },
            child: Text('Yes', style: GoogleFonts.outfit(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }


  Future<void> _endSession() async {
    print('Ending session...');
    _timer?.cancel();
    
    await _tts.speak('Well done. You\'ve let it out. Now, let\'s bring your mind back to calm.');

    if (_sessionType.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
      
      try {
        Map<String, dynamic> result = {};
        
        if (_sessionType == 'text' && _noteText.isNotEmpty) {
           result = await _apiService.logStressBusterSession(
            duration: 120 - _secondsRemaining,
            note: _noteText
          );
        }
        
        _aiFeedback = result['feedback'];
        
        if (mounted) Navigator.pop(context); // Remove loading
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session saved successfully')),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Remove loading
        print('Error saving session: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving session: $e')),
          );
        }
      }
    } else {
      print('No session type selected, skipping save');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select voice or text to save the session')),
        );
      }
    }

    setState(() {
      _sessionCompleted = true;
      _secondsRemaining = 120;
      _noteText = '';
    });
  }

  Color _getTimerColor() {
    if (_secondsRemaining > 90) return Colors.orange.shade300;
    if (_secondsRemaining > 60) return Colors.yellow.shade400;
    if (_secondsRemaining > 30) return AppTheme.primaryColor;
    return Colors.blue.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '2-Minute Stress Buster', 
          style: GoogleFonts.outfit(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancelSession,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textDark),
            onPressed: () => FeatureInfoSheet.show(context, 'stress_buster'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2F1), Color(0xFFE8EAF6)], // Soft teal to lavender
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _sessionCompleted ? _buildPostSessionScreen() : _buildSessionScreen(),
        ),
      ),
    );
  }

  Widget _buildSessionScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Release Your Stress',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
          const SizedBox(height: 8),
          Text(
             "Speak or write what's bothering you for 2 minutes to let it go.",
             textAlign: TextAlign.center,
             style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
          
          const SizedBox(height: 48),
          
          // Timer Circle
          ScaleTransition(
            scale: _breathingAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getTimerColor().withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: _secondsRemaining / 120,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                    backgroundColor: Colors.white.withOpacity(0.5),
                    strokeWidth: 16,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (_isPaused)
                      Text('PAUSED', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14, letterSpacing: 1.2)),
                  ],
                ),
              ],
            ),
          ).animate().scale(duration: const Duration(milliseconds: 500)),
          
          const SizedBox(height: 48),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.orange.shade300,
                onTap: _isPaused ? _resumeTimer : _pauseTimer,
              ),
              const SizedBox(width: 32),
              _buildControlButton(
                icon: Icons.refresh_rounded,
                color: AppTheme.textLight,
                onTap: _restartTimer,
              ),
              const SizedBox(width: 32),
              _buildControlButton(
                icon: Icons.check_rounded,
                color: AppTheme.successColor,
                onTap: _endSession,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: CustomTextField(
              hintText: "What's on your mind? Type it all out...",
              maxLines: 4,
              onChanged: (val) => _noteText = val,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: color, size: 36),
      ),
    );
  }
  

  Widget _buildPostSessionScreen() {
    return SingleChildScrollView(
       padding: const EdgeInsets.all(24),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const SizedBox(height: 20),
           Container(
             padding: const EdgeInsets.all(24),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.9),
               shape: BoxShape.circle,
               boxShadow: [
                 BoxShadow(color: AppTheme.successColor.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)
               ]
             ),
             child: Icon(Icons.check_circle_rounded, size: 72, color: AppTheme.successColor),
           ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
           const SizedBox(height: 32),
           Text(
             'Session Complete',
             style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
           ),
           const SizedBox(height: 12),
           Text(
             'You\'ve taken a brave step by letting it all out. Here is what MAA heard:',
             textAlign: TextAlign.center,
             style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
           ),
           const SizedBox(height: 40),
           
           if (_aiFeedback != null)
             Column(
               children: [
                 GlassCard(
                   padding: const EdgeInsets.all(24),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           const Icon(Icons.auto_awesome, color: AppTheme.accentColor, size: 28),
                           const SizedBox(width: 12),
                           Text(
                             "MAA's Insight", 
                             style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)
                           ),
                         ],
                       ),
                       const SizedBox(height: 20),
                       Text(
                         _aiFeedback!,
                         style: GoogleFonts.outfit(fontSize: 16, height: 1.6, color: AppTheme.textDark),
                       ),
                     ],
                   ),
                 ).animate().slideY(begin: 0.1, end: 0, duration: 600.ms).fadeIn(),
                 const SizedBox(height: 32),
                 // Guidance/Next Steps
                 Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     color: AppTheme.primaryColor.withOpacity(0.08),
                     borderRadius: BorderRadius.circular(24),
                     border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                   ),
                   child: Row(
                     children: [
                       const Icon(Icons.spa_rounded, color: AppTheme.primaryColor, size: 32),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Text(
                           "Consider trying a grounding or breathing exercise to center yourself further.",
                           style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                         ),
                       ),
                     ],
                   ),
                 ).animate().fadeIn(delay: 800.ms),
               ],
             ),
           
           const SizedBox(height: 40),
           
           Row(
             children: [
               Expanded(
                 child: ElevatedButton.icon(
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const GroundingScreen()),
                     );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.white,
                     foregroundColor: AppTheme.primaryColor,
                     padding: const EdgeInsets.symmetric(vertical: 20),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20),
                       side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
                     ),
                     elevation: 2,
                   ),
                   icon: const Icon(Icons.nature_people_rounded, size: 22),
                   label: Text('Grounding', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: ElevatedButton.icon(
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const BreathingScreen()),
                     );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.white,
                     foregroundColor: Colors.blueAccent,
                     padding: const EdgeInsets.symmetric(vertical: 20),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20),
                       side: BorderSide(color: Colors.blueAccent.withOpacity(0.2)),
                     ),
                     elevation: 2,
                   ),
                   icon: const Icon(Icons.air_rounded, size: 22),
                   label: Text('Breathing', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                 ),
               ),
             ],
           ).animate().fadeIn(delay: 1000.ms),
           
           const SizedBox(height: 24),
           
           GradientButton(
             text: "Return Home",
             onPressed: () => Navigator.pop(context),
           ).animate().fadeIn(delay: 1100.ms),
           const SizedBox(height: 40),
         ],
       ),
    );
  }
}