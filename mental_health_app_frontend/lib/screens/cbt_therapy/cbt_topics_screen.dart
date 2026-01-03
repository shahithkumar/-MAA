import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import 'cbt_exercise_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class CBTTopicsScreen extends StatefulWidget {
  const CBTTopicsScreen({super.key});

  @override
  _CBTTopicsScreenState createState() => _CBTTopicsScreenState();
}

class _CBTTopicsScreenState extends State<CBTTopicsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> topics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() => isLoading = true);
    try {
      final loadedTopics = await _apiService.getCBTTopics();
      setState(() {
        topics = loadedTopics;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load topics: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Color _parseColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '').padLeft(6, '0').toUpperCase();
      if (hex.length == 6) {
        return Color(0xFF000000 + int.parse(hex, radix: 16));
      }
      return AppTheme.primaryColor;
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'CBT Therapy',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
            IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textDark),
            onPressed: _loadTopics,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : topics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.psychology, size: 80, color: AppTheme.textLight),
                          const SizedBox(height: 16),
                          Text(
                            'No topics available',
                            style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        final color = _parseColor(topic['color'] ?? '#4CAF50');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CBTExerciseScreen(
                                    topicId: topic['id'],
                                    topicTitle: topic['title'],
                                    topicEmoji: topic['emoji'] ?? '🧠',
                                    topicColor: color,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      topic['emoji'] ?? '🧠',
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          topic['title'] ?? 'Unknown',
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          topic['description'] ?? '',
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            color: AppTheme.textLight,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}