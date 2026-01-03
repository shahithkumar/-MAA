import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'yoga_routine_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class YogaHomeContent extends StatefulWidget {
  const YogaHomeContent({super.key});

  @override
  State<YogaHomeContent> createState() => _YogaHomeContentState();
}

class _YogaHomeContentState extends State<YogaHomeContent> {
  final ApiService _apiService = ApiService();
  int _streak = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Stress Relief', 'icon': Icons.spa_rounded, 'color': Color(0xFFE8F5E9), 'textColor': Color(0xFF2E7D32)},
    {'name': 'Beginner Yoga', 'icon': Icons.accessibility_new_rounded, 'color': Color(0xFFFFF3E0), 'textColor': Color(0xFFEF6C00)},
    {'name': 'Morning Energy', 'icon': Icons.wb_sunny_rounded, 'color': Color(0xFFFFF8E1), 'textColor': Color(0xFFF9A825)},
    {'name': 'Sleep & Relax', 'icon': Icons.nightlight_round, 'color': Color(0xFFECEFF1), 'textColor': Color(0xFF455A64)},
  ];

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _streak = prefs.getInt('yoga_streak') ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Streak Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak',
                        style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textLight),
                      ),
                      Text(
                        '$_streak days',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose your practice',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            // Categories Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return _buildCategoryCard(cat);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YogaRoutineScreen(
              categoryName: category['name'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: category['color'],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category['icon'], size: 36, color: category['textColor']),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                category['name'],
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: category['textColor'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
