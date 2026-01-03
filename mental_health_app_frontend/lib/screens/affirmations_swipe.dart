import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../models/affirmation.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AffirmationsSwipeScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  
  const AffirmationsSwipeScreen({
    super.key, 
    required this.categoryId, 
    this.categoryName = 'Daily Affirmations'
  });
  
  @override
  State<AffirmationsSwipeScreen> createState() => _AffirmationsSwipeScreenState();
}

class _AffirmationsSwipeScreenState extends State<AffirmationsSwipeScreen> {
  List<Affirmation> affirmations = [];
  int currentIndex = 0;
  bool isLoading = true;
  final PageController _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    _loadAffirmations();
  }
  
  Future<void> _loadAffirmations() async {
    try {
      final apiService = ApiService();
      final affirmationData = await apiService.getGenericAffirmations(
        categoryId: widget.categoryId,
      );
      if (mounted) {
        setState(() {
          affirmations = affirmationData.map((json) => Affirmation.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load affirmations', style: GoogleFonts.outfit())),
        );
      }
    }
  }
  
  void _onPageChanged(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
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
            colors: [
              Color(0xFFF3E5F5), // Soft Lavender
              Color(0xFFE1BEE7), // Purple 100
              Color(0xFFE0F7FA), // Light Cyan accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : affirmations.isEmpty
                ? Center(child: Text("No affirmations found", style: GoogleFonts.outfit(color: AppTheme.textDark)))
                : SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: _onPageChanged,
                            physics: const BouncingScrollPhysics(),
                            itemCount: affirmations.length,
                            itemBuilder: (context, index) {
                              final affirmation = affirmations[index];
                              return AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  double value = 1.0;
                                  if (_pageController.position.haveDimensions) {
                                    value = _pageController.page! - index;
                                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                                  }
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                                      child: Transform.scale(
                                        scale: value,
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: _buildAffirmationCard(affirmation),
                              );
                            },
                          ),
                        ),
                        _buildFooter(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildAffirmationCard(Affirmation affirmation) {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 48)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2000.ms, color: Colors.white)
              .scale(duration: 1000.ms, curve: Curves.easeInOut),
          const SizedBox(height: 32),
          Text(
            affirmation.text,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRoundButton(
                icon: Icons.share_rounded,
                onTap: () {
                  // Share functionality
                },
              ),
              const SizedBox(width: 20),
              _buildRoundButton(
                icon: Icons.favorite_rounded,
                onTap: () {
                  // Like functionality
                },
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({required IconData icon, required VoidCallback onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Icon(icon, color: color ?? AppTheme.textDark, size: 24),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Text(
            'Swipe left or right to explore',
            style: GoogleFonts.outfit(
              color: AppTheme.textDark.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentIndex + 1} / ${affirmations.length}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
