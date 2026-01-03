import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class ArticlesSolutionsScreen extends StatefulWidget {
  final int disorderId;

  const ArticlesSolutionsScreen({Key? key, required this.disorderId}) : super(key: key);

  @override
  _ArticlesSolutionsScreenState createState() => _ArticlesSolutionsScreenState();
}

class _ArticlesSolutionsScreenState extends State<ArticlesSolutionsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> articles = [];
  List<Map<String, dynamic>> copingMethods = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getArticles(widget.disorderId),
        _apiService.getCopingMethods(widget.disorderId),
      ]);

      if (mounted) {
        setState(() {
          articles = results[0];
          copingMethods = results[1];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load tools: $e';
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
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(errorMessage!, style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textDark), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            ),
          ],
        ),
      );
    }

    if (articles.isEmpty && copingMethods.isEmpty) {
      return Center(child: Text('No tools available yet.', style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textLight)));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Coping Strategies
          if (copingMethods.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.self_improvement_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Coping Strategies',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...copingMethods.map((method) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      method['title'] ?? 'Untitled Strategy',
                      style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    iconColor: AppTheme.primaryColor,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Text(
                          method['instructions'] ?? 'No instructions available.',
                          style: GoogleFonts.outfit(fontSize: 15, height: 1.6, color: AppTheme.textLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
            const SizedBox(height: 32),
          ],

          // Section 2: Articles
          if (articles.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.article_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Recommended Articles',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...articles.map((article) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'] ?? 'Untitled Article',
                      style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article['content'] ?? '',
                      style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textLight, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    if (article['url'] != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _launchUrl(article['url']),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.primaryColor),
                          label: Text('Read More', style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }
}