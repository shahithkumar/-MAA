import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_card.dart';
import 'articles_solutions.dart';
import 'recovery_roadmap.dart';

class DisorderSummaryScreen extends StatefulWidget {
  final int disorderId;

  const DisorderSummaryScreen({Key? key, required this.disorderId}) : super(key: key);

  @override
  _DisorderSummaryScreenState createState() => _DisorderSummaryScreenState();
}

class _DisorderSummaryScreenState extends State<DisorderSummaryScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? disorder;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDisorderDetails();
  }

  Future<void> _loadDisorderDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _apiService.getDisorderDetails(widget.disorderId);
      if (mounted) {
        setState(() {
          disorder = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load disorder details: $e';
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open article link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text(''), backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppTheme.textDark)),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppTheme.textDark)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text(errorMessage!, style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textDark), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDisorderDetails,
                child: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            disorder?['name'] ?? 'Disorder',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textLight,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.info_outline_rounded), text: 'Overview'),
              Tab(icon: Icon(Icons.library_books_rounded), text: 'Tools'),
              Tab(icon: Icon(Icons.map_rounded), text: 'Roadmap'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            // TAB 1: OVERVIEW
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disorder?['name'] ?? 'Unknown Disorder',
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      disorder?['summary'] ?? 'No description available.',
                      style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textDark, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // External Links Section
                  if (disorder?['article_url'] != null || disorder?['youtube_url'] != null) ...[
                     Text(
                      'External Resources',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (disorder?['article_url'] != null)
                          GradientButton(
                            text: 'Read Article',
                            icon: Icons.article_rounded,
                            onPressed: () => _launchUrl(disorder!['article_url']),
                            // Use default primary colors
                          ),
                        if (disorder?['youtube_url'] != null)
                          GradientButton(
                            text: 'Watch Video',
                            icon: Icons.play_circle_fill_rounded,
                            onPressed: () => _launchUrl(disorder!['youtube_url']),
                            colors: const [Color(0xFFFF8A80), Color(0xFFEF5350)], // Red gradient for YouTube
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // TAB 2: ARTICLES & SOLUTIONS (Embedded)
            ArticlesSolutionsScreen(disorderId: widget.disorderId),

            // TAB 3: RECOVERY ROADMAP (Embedded)
            RecoveryRoadmapScreen(disorderId: widget.disorderId),
          ],
        ),
      ),
    );
  }
}