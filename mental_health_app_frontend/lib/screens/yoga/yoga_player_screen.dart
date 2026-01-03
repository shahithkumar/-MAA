import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'yoga_completion_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class YogaPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final int duration;

  const YogaPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.duration,
  });

  @override
  State<YogaPlayerScreen> createState() => _YogaPlayerScreenState();
}

class _YogaPlayerScreenState extends State<YogaPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    String? id = YoutubePlayer.convertUrlToId(widget.videoId);
    id ??= widget.videoId;

    _controller = YoutubePlayerController(
      initialVideoId: id ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markAsDone() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => YogaCompletionScreen(
          sessionTitle: widget.title,
          duration: widget.duration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // YouTube Player
          Expanded(
            flex: 3,
            child: Center(
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                onReady: () {
                  _isPlayerReady = true;
                },
                progressColors: const ProgressBarColors(
                  playedColor: AppTheme.primaryColor,
                  handleColor: Colors.white,
                ),
              ),
            ),
          ),
          // Instructions & Controls
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧘 Instructions:',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionItem('Sit or stand comfortably providing enough space.'),
                  _buildInstructionItem('Breathe slowly and follow the instructor.'),
                  _buildInstructionItem('Stop if you feel any sharp pain.'),
                  const Spacer(),
                  GradientButton(
                    text: 'Mark as Done',
                    onPressed: _markAsDone,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fiber_manual_record, size: 8, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
