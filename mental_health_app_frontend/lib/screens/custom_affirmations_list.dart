import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../services/api_service.dart';
import '../models/affirmation.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'custom_affirmation_flow.dart';

class CustomAffirmationsListScreen extends StatefulWidget {
  @override
  _CustomAffirmationsListScreenState createState() => _CustomAffirmationsListScreenState();
}

class _CustomAffirmationsListScreenState extends State<CustomAffirmationsListScreen> {
  List<Map<String, dynamic>> affirmations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAffirmations();
  }

  Future<void> _loadAffirmations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try loading from backend
      final apiService = ApiService();
      final data = await apiService.getCustomAffirmations();
      setState(() {
        affirmations = data;
        isLoading = false;
      });
      print('✅ LOADED ${affirmations.length} affirmations from backend');

      // If backend is empty, check local storage
      if (affirmations.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString('custom_affirmations') ?? '[]';
        final localAffirmations = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          affirmations = localAffirmations.map((item) => Map<String, dynamic>.from(item)).toList();
          isLoading = false;
          if (affirmations.isNotEmpty) {
            errorMessage = 'Showing local affirmations (backend sync may have failed)';
          }
        });
        print('✅ LOADED ${affirmations.length} affirmations from SharedPreferences');
      }
    } catch (e) {
      print('❌ Load error: $e');
      // Fallback to SharedPreferences on error
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('custom_affirmations') ?? '[]';
      final localAffirmations = jsonDecode(jsonString) as List<dynamic>;
      setState(() {
        affirmations = localAffirmations.map((item) => Map<String, dynamic>.from(item)).toList();
        isLoading = false;
        errorMessage = 'Failed to load from server: $e. Showing local affirmations.';
      });
      print('✅ LOADED ${affirmations.length} affirmations from SharedPreferences (fallback)');
    }
  }

  Future<void> _deleteAffirmation(int id) async {
    try {
      // Delete from backend
      await ApiService().deleteCustomAffirmation(id);
      // Delete from local storage
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('custom_affirmations') ?? '[]';
      final localAffirmations = jsonDecode(jsonString) as List<dynamic>;
      final updatedAffirmations = localAffirmations.where((aff) => aff['id'] != id).toList();
      await prefs.setString('custom_affirmations', jsonEncode(updatedAffirmations));
      setState(() {
        affirmations = updatedAffirmations.map((item) => Map<String, dynamic>.from(item)).toList();
      });
      print('✅ DELETED affirmation ID: $id');
    } catch (e) {
      print('❌ Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete affirmation: $e')),
      );
    }
  }

  Future<void> _showRandom() async {
    try {
      final randomAff = await ApiService().getRandomCustomAffirmation();
      if (randomAff != null) {
        _showAffirmationDialog(randomAff['affirmation_text'] ?? 'No text available');
      } else {
        // Fallback to local random affirmation
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString('custom_affirmations') ?? '[]';
        final localAffirmations = jsonDecode(jsonString) as List<dynamic>;
        if (localAffirmations.isNotEmpty) {
          final random = Random().nextInt(localAffirmations.length);
          final randomAff = localAffirmations[random];
          _showAffirmationDialog(randomAff['affirmationText'] ?? 'No text available');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No affirmations available')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading affirmation: $e')),
      );
    }
  }

  void _showAffirmationDialog(String text) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.accentColor, size: 48),
              const SizedBox(height: 24),
              Text(
                text,
                style: GoogleFonts.outfit(fontSize: 22, height: 1.4, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: GoogleFonts.outfit(color: AppTheme.textLight, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('My Affirmations', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded, color: AppTheme.textDark),
            onPressed: _showRandom,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE1BEE7)], // Soft Cyan to Lavender
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : affirmations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 80, color: AppTheme.textLight.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No affirmations yet', style: GoogleFonts.outfit(color: AppTheme.textLight, fontSize: 18)),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomAffirmationFlowScreen(),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            child: Text('Create Your First', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: affirmations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final aff = affirmations[index];
                        return GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                aff['focusEmoji'] ?? '🌸',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            title: Text(
                              aff['affirmationText'] ?? aff['affirmation_text'] ?? 'No text',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textDark, fontSize: 16),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                '${aff['focusArea']?.replaceAll('_', ' ') ?? aff['focus_area']?.replaceAll('_', ' ') ?? 'Unknown'}',
                                style: GoogleFonts.outfit(color: AppTheme.textLight, fontSize: 13),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
                              onPressed: () => _deleteAffirmation(aff['id']),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomAffirmationFlowScreen()),
        ),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}