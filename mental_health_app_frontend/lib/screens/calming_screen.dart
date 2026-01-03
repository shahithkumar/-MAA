import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'stress_buster_screen.dart'; 
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'breathing_screen.dart';

class CalmingScreen extends StatefulWidget {
  const CalmingScreen({super.key});

  @override
  _CalmingScreenState createState() => _CalmingScreenState();
}

class _CalmingScreenState extends State<CalmingScreen> {
  final ApiService _apiService = ApiService();
  late AudioPlayer _audioPlayer;
  bool _musicOn = true;
  String _currentTheme = 'ocean';
  Map<String, bool> _actionsLog = {}; 

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playAudio();
    _actionsLog['session_started'] = true; 
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _logSession(); 
    super.dispose();
  }

  void _playAudio() async {
    if (_musicOn) {
      await _audioPlayer.play(UrlSource('${_apiService.baseUrl}/media/soft-audio.mp3'));
    } else {
      await _audioPlayer.stop();
    }
  }

  void _logAction(String action) {
    setState(() => _actionsLog[action] = true);
  }

  Future<void> _logSession() async {
    try {
      await _apiService.logPanicSession(_actionsLog);
    } catch (e) {
      print('Logging failed: $e');
    }
  }

  void _toggleMusic() {
    setState(() => _musicOn = !_musicOn);
    _playAudio();
  }

  void _changeTheme(String theme) {
    setState(() => _currentTheme = theme);
    _logAction('theme_changed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated background image
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              key: ValueKey<String>(_currentTheme),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    _currentTheme == 'ocean'
                        ? '${_apiService.baseUrl}/media/ocean.jpeg'
                        : '${_apiService.baseUrl}/media/forest.jpg',
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(reverse: true),
              effects: [
                ScaleEffect(duration: 20.seconds, begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1)),
              ],
            ),
          ),
          
          // Gradient overlays
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    'You are safe.\nLet\'s slow things down together.',
                    style: GoogleFonts.outfit(
                      fontSize: 28, 
                      color: Colors.white,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4))
                      ]
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 60),
                  
                  // Action Buttons using GlassCard styled InkWells
                  _buildGlassActionButton(
                    icon: Icons.air_rounded,
                    label: 'Guided Breathing',
                    onPressed: () {
                      _logAction('guided_breathing');
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) =>  BreathingScreen())
                      );
                    },
                    delay: 200.ms,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildGlassActionButton(
                    icon: Icons.palette_outlined,
                    label: 'Change Theme',
                    onPressed: () {
                      _logAction('change_theme');
                      _changeTheme(_currentTheme == 'ocean' ? 'forest' : 'ocean');
                    },
                    delay: 300.ms,
                  ),
                  const SizedBox(height: 32),
                  
                  // Clean Audio Toggle
                  GestureDetector(
                    onTap: () {
                      _logAction('toggle_music');
                      _toggleMusic();
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                child: Icon(_musicOn ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Soft Audio', 
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _musicOn ? 'Playing soothing sounds' : 'Audio paused',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _musicOn,
                            onChanged: (val) {
                               _logAction('toggle_music');
                               _toggleMusic();
                            },
                            activeColor: AppTheme.accentColor,
                            activeTrackColor: Colors.white30,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Duration delay,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.1, end: 0);
  }
}