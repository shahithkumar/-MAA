import 'package:flutter/material.dart';

class FeatureInfo {
  final String id;
  final String title;
  final String whatIsIt;
  final String howToUse;
  final String benefits;
  final List<FeatureInfo>? subFeatures;

  const FeatureInfo({
    required this.id,
    required this.title,
    required this.whatIsIt,
    required this.howToUse,
    required this.benefits,
    this.subFeatures,
  });
}

class FeatureContent {
  static const Map<String, FeatureInfo> features = {
    'stress_buster': FeatureInfo(
      id: 'stress_buster',
      title: 'Stress Buster',
      whatIsIt: 'A rapid relief tool designed to help you vent and release immediate tension.',
      howToUse: 'Choose "Voice" to speak or "Text" to write. Spend 2 minutes pouring out everything that is bothering you. We will help you process it.',
      benefits: 'Releasing pent-up emotions (catharsis) lowers cortisol levels, prevents burnout, and clears your mind for better decision-making.',
    ),
    'therapy_room': FeatureInfo(
      id: 'therapy_room',
      title: 'Therapy Room',
      whatIsIt: 'A holistic space offering creative and structured therapeutic activities.',
      howToUse: 'Select from Music Therapy (mood-based playlists), Drawing Therapy (creative expression), or CBT (cognitive exercises).',
      benefits: 'Engages different parts of your brain—creative/emotional and logical—to process complex feelings that words alone cannot fix.',
      subFeatures: [
        FeatureInfo(
          id: 'music_therapy',
          title: 'Music Therapy',
          whatIsIt: 'Mood-based audio therapy utilizing isochronic tones, binaural beats, and solfeggio frequencies.',
          howToUse: 'Select your current emotional state (e.g., Anxious, Sad). Listen to the curated playlist with headphones for best results.',
          benefits: 'Directly influences brainwave activity to induce states of calm, focus, or sleep without conscious effort.',
        ),
        FeatureInfo(
          id: 'drawing_therapy',
          title: 'Drawing Therapy',
          whatIsIt: 'A digital canvas for non-verbal emotional expression.',
          howToUse: 'Choose a guided prompt or use the free-draw canvas. Use colors and shapes to represent your feelings.',
          benefits: 'Bypasses the logical brain to access and release deep-seated emotions that are hard to articulate with words.',
        ),
        FeatureInfo(
          id: 'cbt_therapy',
          title: 'CBT Exercises',
          whatIsIt: 'Structured cognitive exercises to identify and challenge negative thought patterns.',
          howToUse: 'Select a topic like "Anxiety" or "Self-Doubt". Follow the step-by-step prompts to reframe your thoughts.',
          benefits: 'Builds long-term resilience by teaching you how to recognize and alter distorted thinking.',
        ),
      ],
    ),
    'mood_tracker': FeatureInfo(
      id: 'mood_tracker',
      title: 'Mood Tracker',
      whatIsIt: 'A daily log to track your emotional state and identify patterns.',
      howToUse: 'Tap the emoji that best reflects your current mood. You can optionally add a note to explain why.',
      benefits: 'Visualizing your mood history helps you identify triggers, celebrate improvements, and understand your emotional rhythm.',
    ),
    'affirmations': FeatureInfo(
      id: 'affirmations',
      title: 'Daily Affirmations',
      whatIsIt: 'Positive, empowering statements designed to challenge negative self-talk.',
      howToUse: 'Swipe through the cards. Read each affirmation aloud or silently to yourself. Focus on believing the words.',
      benefits: 'Practicing affirmations rewires neural pathways, boosting self-esteem and resilience against stress.',
    ),
    'journal': FeatureInfo(
      id: 'journal',
      title: 'Tri-Modal Journal',
      whatIsIt: 'A flexible journaling tool that supports Text, Audio, and Video entries.',
      howToUse: 'Select your preferred medium. Record a video diary, leave a voice note, or write a classic entry.',
      benefits: 'Expressing yourself in your natural style (speaking vs writing) makes journaling less of a chore and more of an authentic release.',
    ),
    'cbt': FeatureInfo(
      id: 'cbt',
      title: 'CBT Exercises',
      whatIsIt: 'Structured mental exercises based on Cognitive Behavioral Therapy principles.',
      howToUse: 'Choose a topic (e.g., Anxiety, Self-Doubt). Follow the step-by-step prompts to challenge your thoughts.',
      benefits: 'Helps you identify and change destructive thought patterns that negatively influence your behavior and emotions.',
    ),
    'breathing': FeatureInfo(
      id: 'breathing',
      title: '4-7-8 Breathing',
      whatIsIt: 'A breathing technique that acts as a natural tranquilizer for the nervous system.',
      howToUse: 'Inhale through your nose for 4 seconds, hold for 7 seconds, and exhale forcefully for 8 seconds.',
      benefits: 'Forces your body to switch from "fight or flight" mode to "rest and digest," rapidly lowering heart rate and anxiety.',
    ),
    'grounding': FeatureInfo(
      id: 'grounding',
      title: '5-4-3-2-1 Grounding',
      whatIsIt: 'A mindfulness technique to anchor you in the present moment.',
      howToUse: 'Identify 5 things you see, 4 you touch, 3 you hear, 2 you smell, and 1 you taste.',
      benefits: 'Distracts the brain from anxious loops and flashbacks, bringing your focus back to physical reality.',
    ),
    'meditation_yoga': FeatureInfo(
      id: 'meditation_yoga',
      title: 'Meditation & Yoga',
      whatIsIt: 'Guided audio and physical sessions for mind-body connection.',
      howToUse: 'Browse the library and select a session that matches your need (e.g., Sleep, Focus, Relaxation).',
      benefits: 'Reduces physical tension, improves focus, and promotes long-term emotional stability.',
    ),
  };
}
