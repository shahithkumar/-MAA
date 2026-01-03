import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'cbt_reflection_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';

class CBTExerciseScreen extends StatefulWidget {
  final int topicId;
  final String topicTitle;
  final String topicEmoji;
  final Color topicColor;

  const CBTExerciseScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
    required this.topicEmoji,
    required this.topicColor,
  });

  @override
  _CBTExerciseScreenState createState() => _CBTExerciseScreenState();
}

class _CBTExerciseScreenState extends State<CBTExerciseScreen> {
  final ApiService _apiService = ApiService();
  final List<String> steps = [
    'Situation',
    'Automatic Thoughts',
    'Emotions',
    'Evidence For',
    'Evidence Against',
    'Balanced Thought',
  ];
  
  final List<String> stepDescriptions = [
    'Describe what happened properly.',
    'What went through your mind?',
    'What did you feel?',
    'Is there fact-based evidence supporting this thought?',
    'Is there evidence contradicting this thought?',
    'What is a more realistic way to view this?',
  ];

  final List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  int currentStep = 0;
  DateTime startTime = DateTime.now();
  final PageController _pageController = PageController();
  bool _isSaving = false;

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      if (controllers[currentStep].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a response to continue."))
        );
        return;
      }
      setState(() => currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _saveCBTSession();
    }
  }

  Future<void> _saveCBTSession() async {
    setState(() => _isSaving = true);
    final responses = controllers.map((c) => c.text.trim()).toList();
    final sessionDuration = DateTime.now().difference(startTime).inSeconds;

    try {
      final result = await _apiService.saveCBTSession(
        topicId: widget.topicId,
        situation: responses[0],
        automaticThought: responses[1],
        emotions: responses[2],
        evidenceFor: responses[3],
        evidenceAgainst: responses[4],
        balancedThought: responses[5],
        sessionDuration: sessionDuration,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CBTReflectionScreen(
            topicId: widget.topicId,
            responses: responses,
            sessionDuration: sessionDuration,
            aiAnalysis: result['ai_analysis'],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.topicTitle, 
          style: GoogleFonts.outfit(
            color: AppTheme.textDark, 
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentStep + 1) / steps.length,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(widget.topicColor),
                  minHeight: 6,
                ),
              ),
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                onPageChanged: (index) => setState(() => currentStep = index),
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.topicColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold,
                              color: widget.topicColor
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          steps[index],
                          style: GoogleFonts.outfit(
                            fontSize: 28, 
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          stepDescriptions[index],
                          style: GoogleFonts.outfit(
                            fontSize: 18, 
                            color: AppTheme.textLight,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        CustomTextField(
                          controller: controllers[index],
                          hintText: "Reflect on this...",
                          maxLines: 10,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GradientButton(
                text: currentStep == steps.length - 1 ? 'Finish & Save' : 'Next Step',
                onPressed: _isSaving ? () {} : _nextStep,
                isLoading: _isSaving,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}