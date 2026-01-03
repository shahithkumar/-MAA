import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';

class DrawingReflectionScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final Uint8List drawingBytes;

  const DrawingReflectionScreen({
    super.key,
    required this.session,
    required this.drawingBytes,
  });

  @override
  State<DrawingReflectionScreen> createState() => _DrawingReflectionScreenState();
}

class _DrawingReflectionScreenState extends State<DrawingReflectionScreen> {
  final ApiService _apiService = ApiService();
  String? _moodAfter;
  final TextEditingController _notesController = TextEditingController();
  final Map<int, String> _answers = {};
  bool _isSubmitting = false;

  final List<String> _moods = [
    'Relieved', 'Proud', 'Calm', 'Confused', 'Same'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_moodAfter == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("How do you feel about your art?")));
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
        moodBefore: 'Unknown', 
        moodAfter: _moodAfter,
        reflectionNotes: _notesController.text,
        drawingBytes: widget.drawingBytes,
        answers: answersList,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Artwork & Reflection saved!")),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
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
        title: Text('Reflect on Art', style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(widget.drawingBytes, height: 250, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),
            
             // Mood Check
            Text(
              "How does this drawing make you feel?",
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

            // Questions
            if (questions.isNotEmpty) ...[
              Text("Guided Questions", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
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
                        hintText: "Your thoughts...",
                        maxLines: 2,
                        onChanged: (val) => _answers[q['id']] = val,
                      ),
                    ],
                  ),
                );
              }),
            ],

            Text("Any other notes?", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _notesController,
              hintText: "Describe your art...",
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            GradientButton(
              text: "Save to Portfolio",
              onPressed: _isSubmitting ? null : _submit,
              isLoading: _isSubmitting,
              icon: Icons.save_alt_rounded,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
