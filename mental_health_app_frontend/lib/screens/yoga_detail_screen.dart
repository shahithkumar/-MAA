import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class YogaDetailScreen extends StatefulWidget {
  final int id;

  const YogaDetailScreen({super.key, required this.id});

  @override
  _YogaDetailScreenState createState() => _YogaDetailScreenState();
}

class _YogaDetailScreenState extends State<YogaDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _yoga;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _bgmPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchYoga();
  }

  Future<void> _fetchYoga() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getYogaDetail(widget.id);
      if (mounted) {
        setState(() {
          _yoga = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load yoga session: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleMainAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else if (_yoga?['audio_file'] != null) {
      String path = _yoga!['audio_file'];
      final String fullUrl = path.startsWith('http') ? path : '${_apiService.baseUrl}$path';
      await _audioPlayer.play(UrlSource(fullUrl));
    }
    if (mounted) setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _toggleBackgroundMusic() async {
    if (_bgmPlaying) {
      await _bgmPlayer.pause();
    } else if (_yoga?['background_music'] != null) {
      String path = _yoga!['background_music'];
      final String fullUrl = path.startsWith('http') ? path : '${_apiService.baseUrl}$path';
      await _bgmPlayer.play(UrlSource(fullUrl));
    }
    if (mounted) setState(() => _bgmPlaying = !_bgmPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Yoga Session',
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFF3E5F5)], // Soft Cyan to Soft Lavender
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 80, color: AppTheme.errorColor),
                          const SizedBox(height: 20),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchYoga,
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _yoga == null
                    ? const Center(child: Text('No data found'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.self_improvement_rounded, color: AppTheme.primaryColor, size: 48),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    '${_yoga!['title']} ${_yoga!['emoji'] ?? ''}',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _yoga!['description'],
                                    style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight, height: 1.5),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.timer_outlined, size: 18, color: AppTheme.accentColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_yoga!['duration']} min', 
                                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentColor)
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms),
                            
                            const SizedBox(height: 32),
                            
                            if (_yoga!['audio_file'] != null || _yoga!['background_music'] != null)
                              GlassCard(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Session Audio', 
                                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    if (_yoga!['audio_file'] != null) ...[
                                      _buildAudioControl(
                                        icon: Icons.play_arrow_rounded,
                                        label: 'Instructor Audio',
                                        isPlaying: _isPlaying,
                                        onToggle: _toggleMainAudio,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    
                                    if (_yoga!['background_music'] != null)
                                      _buildAudioControl(
                                        icon: Icons.spa_rounded,
                                        label: 'Background Music',
                                        isPlaying: _bgmPlaying,
                                        onToggle: _toggleBackgroundMusic,
                                      ),
                                  ],
                                ),
                              ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 200.ms),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildAudioControl({
    required IconData icon,
    required String label,
    required bool isPlaying,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPlaying ? AppTheme.primaryColor : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : icon,
              color: isPlaying ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  isPlaying ? 'Active' : 'Tap to start',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
              size: 36,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}