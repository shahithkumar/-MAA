import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'disorder_summary.dart';

class DisorderSelectionScreen extends StatefulWidget {
  const DisorderSelectionScreen({Key? key}) : super(key: key);

  @override
  _DisorderSelectionScreenState createState() => _DisorderSelectionScreenState();
}

class _DisorderSelectionScreenState extends State<DisorderSelectionScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> disorders = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDisorders();
  }

  Future<void> _loadDisorders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedDisorders = await _apiService.getDisorders();
      if (mounted) {
        setState(() {
          disorders = loadedDisorders;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load disorders: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Resources Hub', style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFE0F7FA), Color(0xFFF3E5F5)], // Soft Teal to Lavender
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : errorMessage != null && disorders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorColor),
                        const SizedBox(height: 16),
                        Text(errorMessage!, style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textDark), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDisorders,
                          child: const Text('Retry'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  )
                : disorders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 64, color: AppTheme.textLight),
                            const SizedBox(height: 16),
                            Text('No disorders available', style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textDark)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadDisorders,
                              child: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDisorders,
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: disorders.length,
                          itemBuilder: (context, index) {
                            final disorder = disorders[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DisorderSummaryScreen(disorderId: disorder['id']),
                                  ),
                                );
                              },
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      ),
                                      child: Text(
                                        disorder['emoji'] ?? '🧠',
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      disorder['name'] ?? 'Unknown',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Tap to learn more",
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
                          },
                        ),
                      ),
      ),
    );
  }
}