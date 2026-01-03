import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';

class MusicReflectionScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final String moodBefore;

  const MusicReflectionScreen({
    super.key,
    required this.session,
    required this.moodBefore,
  });

  @override
  State<MusicReflectionScreen> createState() => _MusicReflectionScreenState();
}

class _MusicReflectionScreenState extends State<MusicReflectionScreen> {
  final ApiService _apiService = ApiService();
  String? _moodAfter;
  final TextEditingController _notesController = TextEditingController();
  final Map<int, String> _answers = {}; 
  bool _isSubmitting = false;

  final List<String> _moods = [
    'Much Better', 'A Bit Better', 'Same', 'Worse'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_moodAfter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select how you feel now.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      List<Map<String, dynamic>> answersList = [];
      _answers.forEach((qId, text) {
        answersList.add({
          'question_id': qId,
          'answer_text': text,
        });
      });

      await _apiService.submitTherapyRecord(
        sessionId: widget.session['id'],
        moodBefore: widget.moodBefore,
        moodAfter: _moodAfter,
        reflectionNotes: _notesController.text,
        answers: answersList,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Session saved! Great job.", style: GoogleFonts.outfit())),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> questions = widget.session['questions'] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Reflection', style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade400, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    "Session Complete",
                    style: GoogleFonts.outfit(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.session['title'],
                    style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Mood Check
            Text(
              "How do you feel compared to before?",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moods.map((mood) {
                final isSelected = _moodAfter == mood;
                return ChoiceChip(
                  label: Text(mood),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
                  ),
                  onSelected: (selected) => setState(() => _moodAfter = selected ? mood : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Dynamic Questions
            if (questions.isNotEmpty) ...[
              Text("Deep Dive", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 16),
              ...questions.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q['question_text'], style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textDark)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "Your answer...",
                        maxLines: 2,
                        onChanged: (val) => _answers[q['id']] = val,
                      ),
                    ],
                  ),
                );
              }),
            ],

            // General Notes
            Text("Other thoughts?", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _notesController,
              hintText: "Write your thoughts here...",
              maxLines: 4,
            ),
            const SizedBox(height: 40),

            // Submit
            GradientButton(
              text: "Save Entry",
              onPressed: _isSubmitting ? () {} : _submit,
              isLoading: _isSubmitting,
              icon: Icons.save_rounded,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
