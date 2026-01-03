import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AffirmationCategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const AffirmationCategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<AffirmationCategoryDetailScreen> createState() => _AffirmationCategoryDetailScreenState();
}

class _AffirmationCategoryDetailScreenState extends State<AffirmationCategoryDetailScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> affirmations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAffirmations();
  }

  Future<void> _loadAffirmations() async {
    try {
      setState(() => isLoading = true);
      affirmations = await _apiService.getGenericAffirmations(categoryId: widget.categoryId);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.categoryName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1BEE7), Color(0xFFF3E5F5)], // Matching affirmations home gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : error != null
                  ? Center(child: Text(error!, style: GoogleFonts.outfit(color: AppTheme.errorColor)))
                  : affirmations.isEmpty
                      ? Center(child: Text('No affirmations found', style: GoogleFonts.outfit(color: AppTheme.textLight)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: affirmations.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final affirmation = affirmations[index];
                            return GlassCard(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    const Icon(Icons.favorite, color: AppTheme.accentColor, size: 28),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        affirmation['text'] ?? '',
                                        style: GoogleFonts.outfit(fontSize: 16, height: 1.4, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryColor),
                                      onPressed: () => _speakAffirmation(affirmation['text']),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
                          },
                        ),
        ),
      ),
    );
  }

  void _speakAffirmation(String text) {
    // Placeholder for TTS logic - consider moving TTS to a shared service if heavily used
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speaking...'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}