import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class MusicReflectionScreen extends StatefulWidget {
  final int categoryId;
  final int sessionDuration;
  final List<int> playedTrackIds;

  const MusicReflectionScreen({
    super.key,
    required this.categoryId,
    required this.sessionDuration,
    required this.playedTrackIds,
  });

  @override
  _MusicReflectionScreenState createState() => _MusicReflectionScreenState();
}

class _MusicReflectionScreenState extends State<MusicReflectionScreen> {
  final ApiService _apiService = ApiService();
  String? selectedMoodChange;
  String? selectedEmotion;
  final List<String> moodOptions = [
    'much_better',
    'a_bit_better',
    'same',
    'worse',
  ];
  final List<String> emotionOptions = [
    'Calm', 'Happy', 'Focused', 'Sleepy', 'Sad', 'Relaxed', 'Energized'
  ];

  final Map<String, String> moodLabels = {
    'much_better': 'Much Better 😊',
    'a_bit_better': 'A Bit Better 🙂',
    'same': 'Same 😐',
    'worse': 'Worse 😞',
  };

  final Map<String, IconData> emotionIcons = {
    'Calm': Icons.favorite_border,
    'Happy': Icons.sentiment_very_satisfied,
    'Focused': Icons.visibility,
    'Sleepy': Icons.nights_stay,
    'Sad': Icons.sentiment_dissatisfied,
    'Relaxed': Icons.spa,
    'Energized': Icons.bolt,
  };

  Future<void> _saveSession() async {
    if (selectedMoodChange == null || selectedEmotion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete the reflection'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _apiService.saveMusicSession(
        categoryId: widget.categoryId,
        tracksPlayed: widget.playedTrackIds,
        moodChange: selectedMoodChange!,
        currentEmotion: selectedEmotion!,
        sessionDuration: widget.sessionDuration,
      );

      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Session saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Session Reflection',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Text
                Text(
                  'How was your music session?',
                  style: GoogleFonts.lora(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                Text(
                  'Take a moment to reflect on your experience 🎵',
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    color: Colors.deepPurple.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 40),

                // Mood Change Section
                _buildSectionCard(
                  title: '1. How did your mood change?',
                  icon: Icons.mood,
                  children: moodOptions.map((option) {
                    final label = moodLabels[option] ?? option;
                    final isSelected = selectedMoodChange == option;
                    return _buildRadioTile(
                      context,
                      value: option,
                      groupValue: selectedMoodChange,
                      title: label,
                      icon: _getMoodIcon(option),
                      isSelected: isSelected,
                      onChanged: (value) => setState(() => selectedMoodChange = value),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Current Emotion Section
                _buildSectionCard(
                  title: '2. What emotion are you feeling now?',
                  icon: Icons.psychology,
                  children: emotionOptions.map((emotion) {
                    final isSelected = selectedEmotion == emotion;
                    return _buildRadioTile(
                      context,
                      value: emotion,
                      groupValue: selectedEmotion,
                      title: emotion,
                      icon: emotionIcons[emotion],
                      isSelected: isSelected,
                      onChanged: (value) => setState(() => selectedEmotion = value),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 60),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade500,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.deepPurple.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Save & Finish',
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple.shade500, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.lora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required String value,
    required String? groupValue,
    required String title,
    IconData? icon,
    required bool isSelected,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.deepPurple.shade50
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.deepPurple.shade300
                  : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: Colors.deepPurple.shade500,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.deepPurple.shade500
                      : Colors.grey.shade400,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.deepPurple.shade800
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMoodIcon(String option) {
    switch (option) {
      case 'much_better':
        return Icons.sentiment_very_satisfied;
      case 'a_bit_better':
        return Icons.sentiment_satisfied;
      case 'same':
        return Icons.sentiment_neutral;
      case 'worse':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.mood;
    }
  }
}