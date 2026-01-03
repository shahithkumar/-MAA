import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'music_reflection_screen.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final String moodBefore;

  const MusicPlayerScreen({
    super.key,
    required this.session,
    required this.moodBefore,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudio();
  }

  void _setupAudio() async {
    final url = widget.session['audio_file'];
    if (url != null) {
      String fullUrl = url;
      if (!url.startsWith('http')) {
        fullUrl = '${_apiService.baseUrl}$url';
      }
      
      try {
        await _audioPlayer.setSourceUrl(fullUrl);
        await _audioPlayer.resume();
        setState(() => _isPlaying = true);
      } catch (e) {
        debugPrint("Error loading audio: $e");
      }
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    
    _audioPlayer.onPlayerComplete.listen((event) {
       setState(() {
         _isPlaying = false;
         _position = Duration.zero;
       });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _finishSession() {
    _audioPlayer.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MusicReflectionScreen(
          session: widget.session,
          moodBefore: widget.moodBefore,
        ),
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.session['image'] != null;
    final imageUrl = hasImage 
        ? (widget.session['image'].startsWith('http') 
            ? widget.session['image'] 
            : '${_apiService.baseUrl}${widget.session['image']}')
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background
          if (hasImage) 
            Container(
               decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                ),
              ),
            )
          else
             Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Colors.deepPurple.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Album Art / Icon area
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 100,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Title & Subtitle
                  Text(
                    widget.session['title'],
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Immerse yourself in the sound",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      min: 0,
                      max: _duration.inSeconds.toDouble() + 1.0,
                      onChanged: (value) async {
                        await _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTime(_position), style: GoogleFonts.outfit(color: Colors.white70)),
                        Text(_formatTime(_duration), style: GoogleFonts.outfit(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white70),
                        iconSize: 36,
                        onPressed: () => _audioPlayer.seek(_position - const Duration(seconds: 10)),
                      ),
                      const SizedBox(width: 30),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          iconSize: 48,
                          color: AppTheme.primaryColor,
                          padding: const EdgeInsets.all(12),
                          onPressed: _togglePlay,
                        ),
                      ),
                      const SizedBox(width: 30),
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white70),
                        iconSize: 36,
                        onPressed: () => _audioPlayer.seek(_position + const Duration(seconds: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Finish Button
                  TextButton(
                    onPressed: _finishSession,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      "Complete & Reflect",
                      style: GoogleFonts.outfit(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
