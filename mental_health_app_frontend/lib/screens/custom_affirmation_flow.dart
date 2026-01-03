import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';
import 'custom_affirmations_list.dart';

class CustomAffirmationFlowScreen extends StatefulWidget {
  const CustomAffirmationFlowScreen({super.key});

  @override
  State<CustomAffirmationFlowScreen> createState() => _CustomAffirmationFlowScreenState();
}

class _CustomAffirmationFlowScreenState extends State<CustomAffirmationFlowScreen> {
  final ApiService _apiService = ApiService();
  int currentStep = 0;
  bool isLoading = false;
  
  // Data
  String focusArea = '';
  String focusEmoji = '';
  String challenge = '';
  String positiveDirection = '';
  
  // AI Generation
  int affirmationCount = 3; 
  List<String> generatedAffirmations = [];
  String? selectedAffirmation;
  
  late TextEditingController _challengeController;
  late TextEditingController _directionController;
  
  static const int totalSteps = 4;
  
  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Choose Focus',
      'question': 'What do you want to cultivate?',
      'type': 'selection',
      'options': [
        {'name': 'Calm', 'emoji': '🌿', 'value': 'calm'},
        {'name': 'Confidence', 'emoji': '💪', 'value': 'confidence'},
        {'name': 'Self-Love', 'emoji': '💖', 'value': 'self_love'},
        {'name': 'Motivation', 'emoji': '✨', 'value': 'motivation'},
        {'name': 'Peace', 'emoji': '🌤️', 'value': 'peace'},
      ],
    },
    {
      'title': 'Your Challenge',
      'question': 'What\'s been difficult for you?',
      'hint': 'e.g., "I feel anxious", "I doubt myself"',
      'type': 'challenge',
    },
    {
      'title': 'Positive Choice',
      'question': 'What do you choose instead?',
      'hint': 'e.g., "I stay calm", "I believe in myself"',
      'type': 'direction',
    },
    {
      'title': 'AI Generation',
      'question': 'Select number of variations',
      'type': 'generate',
    },
  ];

  @override
  void initState() {
    super.initState();
    _challengeController = TextEditingController();
    _directionController = TextEditingController();
  }

  @override
  void dispose() {
    _challengeController.dispose();
    _directionController.dispose();
    super.dispose();
  }

  double get progress => ((currentStep + 1) / totalSteps).clamp(0.0, 1.0);

  Future<void> _nextStep() async {
    if (isLoading) return;
    
    switch (currentStep) {
      case 0: // Focus
        if (focusArea.isEmpty) {
          _showSnackBar('Please select a focus area', AppTheme.errorColor);
          return;
        }
        setState(() => currentStep++);
        break;
        
      case 1: // Challenge
        challenge = _challengeController.text.trim();
        if (challenge.isEmpty) {
          _showSnackBar('Please enter your challenge', AppTheme.errorColor);
          return;
        }
        setState(() => currentStep++);
        break;
        
      case 2: // Positive Direction
        positiveDirection = _directionController.text.trim();
        if (positiveDirection.isEmpty) {
          _showSnackBar('Please enter your positive choice', AppTheme.errorColor);
          return;
        }
        setState(() => currentStep++);
        break;
        
      case 3: // Generate
        await _generateAIAffirmations();
        break;
    }
  }

  Future<void> _generateAIAffirmations() async {
    setState(() => isLoading = true);
    
    try {
      final contextText = "Focus: $focusArea. Challenge: $challenge. Direction: $positiveDirection.";
      
      final results = await _apiService.generateAIAffirmations(
        context: contextText,
        count: affirmationCount,
      );
      
      if (mounted) {
        setState(() {
          generatedAffirmations = results;
          isLoading = false;
        });
        
        if (results.isEmpty) {
           _showSnackBar('Failed to generate. Please try again.', AppTheme.errorColor);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnackBar('Error: $e', AppTheme.errorColor);
      }
    }
  }
  
  Future<void> _saveSelectedAffirmation() async {
    if (selectedAffirmation == null) return;
    setState(() => isLoading = true);
    
    try {
      await _apiService.createCustomAffirmation(
        text: selectedAffirmation!,
        focusArea: focusArea,
        challenge: challenge,
        direction: positiveDirection,
      );
      
      if (mounted) {
        setState(() => isLoading = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnackBar('Save Error: $e', AppTheme.errorColor);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.successColor, size: 64),
              const SizedBox(height: 24),
              Text('Saved!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 12),
              Text(
                'Your custom affirmation has been saved to your profile.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppTheme.textLight, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to home
                    },
                    child: Text('Done', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  ),
                  TextButton(
                    onPressed: () {
                       Navigator.pop(context);
                       _showMyAffirmations();
                    },
                    child: Text('View All', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showMyAffirmations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomAffirmationsListScreen(),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _selectFocus(Map<String, dynamic> option) {
    setState(() {
      focusArea = option['value'];
      focusEmoji = option['emoji'];
    });
    _nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  step['title'],
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Question
                Text(
                  step['question'],
                  style: GoogleFonts.outfit(fontSize: 16, height: 1.5, color: AppTheme.textLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Content
                Expanded(
                  child: _buildStepContent(step),
                ),
                
                const SizedBox(height: 24),

                // Bottom Button (Only for intermediate steps)
                if (currentStep < 3)
                   GradientButton(
                     text: currentStep == 2 ? 'Next: AI Generation' : 'Next',
                     onPressed: isLoading ? null : _nextStep,
                     icon: Icons.arrow_forward_rounded,
                   )
                else if (generatedAffirmations.isNotEmpty)
                   GradientButton(
                     text: "Save Selected",
                     onPressed: selectedAffirmation != null && !isLoading ? _saveSelectedAffirmation : null,
                     isLoading: isLoading,
                     icon: Icons.check_circle_rounded,
                   ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(Map<String, dynamic> step) {
    switch (step['type']) {
      case 'selection':
        return ListView.builder(
          itemCount: step['options'].length,
          itemBuilder: (context, index) {
            final option = step['options'][index];
            final isSelected = focusArea == option['value'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _selectFocus(option),
                borderRadius: BorderRadius.circular(20),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Row(
                    children: [
                      Text(option['emoji'], style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Text(
                        option['name'], 
                        style: GoogleFonts.outfit(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textDark,
                        )
                      ),
                      const Spacer(),
                      if (isSelected) 
                        const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        
      case 'challenge':
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _challengeController,
                hintText: step['hint'],
                prefixIcon: Icons.wb_cloudy_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Text(
                'Focus on expressing how you truly feel.',
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textLight, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );
        
      case 'direction':
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _directionController,
                hintText: step['hint'],
                prefixIcon: Icons.wb_sunny_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Text(
                'Focus on what you want to embody.',
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textLight, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );
        
      case 'generate':
        if (generatedAffirmations.isNotEmpty) {
          return ListView.separated(
            itemCount: generatedAffirmations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final aff = generatedAffirmations[index];
              final isSelected = selectedAffirmation == aff;
              return GestureDetector(
                onTap: () => setState(() => selectedAffirmation = aff),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            aff,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: isSelected ? AppTheme.primaryColor : AppTheme.textDark,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected) 
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Variations', style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight)),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.2),
                      thumbColor: AppTheme.primaryColor,
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: affirmationCount.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: affirmationCount.toString(),
                      onChanged: (val) => setState(() => affirmationCount = val.toInt()),
                    ),
                  ),
                  Text(
                    '$affirmationCount Affirmations', 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (isLoading)
              const CircularProgressIndicator(color: AppTheme.primaryColor)
            else
              GradientButton(
                text: "Generate with AI",
                icon: Icons.auto_awesome_rounded,
                onPressed: _generateAIAffirmations,
              ),
          ],
        );
        
      default:
        return const SizedBox();
    }
  }
}