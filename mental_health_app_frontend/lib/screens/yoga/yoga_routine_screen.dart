import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'yoga_player_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class YogaRoutineScreen extends StatefulWidget {
  final String categoryName;

  const YogaRoutineScreen({super.key, required this.categoryName});

  @override
  State<YogaRoutineScreen> createState() => _YogaRoutineScreenState();
}

class _YogaRoutineScreenState extends State<YogaRoutineScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      final allSessions = await _apiService.getYogaSessions();
      if (mounted) {
        setState(() {
          // In a real app, query by category. Here assuming client-side or all for demo.
          _sessions = allSessions; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching yoga sessions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.categoryName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.self_improvement_rounded, size: 80, color: AppTheme.textLight.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No sessions found yet.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return _buildVideoCard(session);
                  },
                ),
    );
  }

  Widget _buildVideoCard(dynamic session) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        onTap: () {
          if (session['video_url'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YogaPlayerScreen(
                  videoId: session['video_url'],
                  title: session['title'] ?? 'Yoga Session',
                  duration: session['duration'] ?? 10,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No video URL available for this session')),
            );
          }
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session['title'] ?? 'Untitled Session',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (session['channel_name'] != null)
                    Text(
                      session['channel_name'],
                      style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${session['duration'] ?? 10} min',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
