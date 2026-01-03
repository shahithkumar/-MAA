import 'package:flutter/material.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'music_reflection_screen.dart';

/*class MusicPlayerScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String categoryEmoji;
  final Color categoryColor;
  final List<Map<String, dynamic>> tracks;

  const MusicPlayerScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryEmoji,
    required this.categoryColor,
    required this.tracks,
  }) : super(key: key);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;  // Main player (like Meditation's main)
  final ApiService _apiService = ApiService();
  int currentTrackIndex = 0;
  bool isPlaying = false;
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;
  List<int> playedTrackIds = [];
  DateTime startTime = DateTime.now();
  bool showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    WidgetsBinding.instance.addObserver(this);
    _loadFirstTrack();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed && isPlaying) {
      _audioPlayer.resume();
    }
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();
    
    await _audioPlayer.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    ));

    // Essential listeners (like Meditation – no onLog to avoid errors)
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() => isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => totalDuration = d);
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() => currentDuration = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _nextTrack();
    });
  }

  Future<void> _loadFirstTrack() async {
    if (widget.tracks.isNotEmpty) {
      await _playTrack(0);
    }
  }

  Future<void> _playTrack(int index) async {
    if (index >= widget.tracks.length) return;

    final track = widget.tracks[index];
    final audioPath = track['audio_file'] ?? track['audio_url'] ?? track['url'];  // Inspired: Handle both fields like Meditation's 'audio_file'
    
    if (audioPath == null || audioPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No audio URL for ${track['title']}')),
      );
      return;
    }

    try {
      print('🔊 Playing track: ${track['title']} - URL: $audioPath');
      
      // Inspired from Meditation: Direct stop + play (no extra delay if not racing)
      await _audioPlayer.stop();
      final String fullUrl = audioPath.startsWith('http') ? audioPath : '${_apiService.baseUrl}$audioPath';
      await _audioPlayer.play(
        UrlSource(
          fullUrl,
          mimeType: 'audio/mpeg',  // FIXED: MP3 MIME for web (fixes Format error Code 4)
        ),
      );
      
      setState(() {
        currentTrackIndex = index;
        isPlaying = true;
        if (!playedTrackIds.contains(track['id'])) {
          playedTrackIds.add(track['id']);
        }
      });

      print('✅ Track started: ${track['title']}');
    } catch (e) {
      print('❌ Failed to play track: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play ${track['title']}: $e')),
      );
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      // Inspired from Meditation: Simple pause/resume (no delay – Meditation doesn't have races)
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      print('❌ Play/pause error: $e');
    }
  }

  Future<void> _nextTrack() async {
    if (currentTrackIndex < widget.tracks.length - 1) {
      await _playTrack(currentTrackIndex + 1);
    } else {
      _endSession();
    }
  }

  Future<void> _previousTrack() async {
    if (currentTrackIndex > 0) {
      await _playTrack(currentTrackIndex - 1);
    }
  }

  Future<void> _endSession() async {
    try {
      await _audioPlayer.stop();
      final totalDurationSeconds = DateTime.now().difference(startTime).inSeconds;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MusicReflectionScreen(
            categoryId: widget.categoryId,
            sessionDuration: totalDurationSeconds,
            playedTrackIds: playedTrackIds,
          ),
        ),
      );
    } catch (e) {
      print('❌ End session error: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = widget.tracks.isNotEmpty ? widget.tracks[currentTrackIndex] : null;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.categoryEmoji, style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.categoryName,
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.categoryColor.withOpacity(0.4),
                widget.categoryColor.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _endSession,
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.categoryColor.withOpacity(0.05),
              widget.categoryColor.withOpacity(0.02),
              Colors.white.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Track List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                itemCount: widget.tracks.length,
                itemBuilder: (context, index) {
                  final track = widget.tracks[index];
                  final isCurrent = index == currentTrackIndex;
                  return Card(
                    elevation: isCurrent ? 8 : 4,
                    shadowColor: widget.categoryColor.withOpacity(isCurrent ? 0.4 : 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: isCurrent ? widget.categoryColor.withOpacity(0.1) : Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: isCurrent ? widget.categoryColor : Colors.grey.shade300,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        track['title'] ?? 'Unknown Track',
                        style: GoogleFonts.lora(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? widget.categoryColor : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${(track['duration'] ?? 180) ~/ 60} min • ${track['artist'] ?? 'Unknown'}',
                        style: GoogleFonts.lora(
                          color: isCurrent ? widget.categoryColor : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isCurrent 
                          ? Icon(
                              Icons.play_arrow,
                              color: widget.categoryColor,
                              size: 28,
                            )
                          : Icon(
                              Icons.music_note,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                      selected: isCurrent,
                      onTap: () => _playTrack(index),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Player Controls
            if (showControls && currentTrack != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Current Track Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentTrack['title'] ?? 'Unknown Track',
                            style: GoogleFonts.lora(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.categoryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentTrack['artist'] ?? '',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              color: widget.categoryColor.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Progress Bar
                    Text(
                      _formatDuration(currentDuration),
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Slider(
                      value: totalDuration.inSeconds > 0 
                          ? currentDuration.inSeconds / totalDuration.inSeconds 
                          : 0.0,
                      onChanged: totalDuration.inSeconds > 0 
                          ? (value) {
                              _audioPlayer.seek(Duration(
                                seconds: (value * totalDuration.inSeconds).toInt(),
                              ));
                            }
                          : null,
                      activeColor: widget.categoryColor,
                      inactiveColor: Colors.grey.shade300,
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Play Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: _previousTrack,
                          iconSize: 40,
                          color: widget.categoryColor,
                          style: IconButton.styleFrom(
                            backgroundColor: widget.categoryColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: widget.categoryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 48,
                              color: widget.categoryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: _nextTrack,
                          iconSize: 40,
                          color: widget.categoryColor,
                          style: IconButton.styleFrom(
                            backgroundColor: widget.categoryColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bottom Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 140,
                          child: ElevatedButton.icon(
                            onPressed: _endSession,
                            icon: const Icon(Icons.stop, color: Colors.white, size: 18),
                            label: const Text(
                              'End Session',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade500,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        Text(
                          '${playedTrackIds.length}/${widget.tracks.length} tracks played',
                          style: GoogleFonts.lora(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ]
          ),
      ),     
            );
  }
}

      */