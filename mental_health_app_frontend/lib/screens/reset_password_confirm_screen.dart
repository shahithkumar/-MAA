import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';

class ResetPasswordConfirmScreen extends StatefulWidget {
  final String uid;
  final String token;

  const ResetPasswordConfirmScreen({super.key, required this.uid, required this.token});

  @override
  _ResetPasswordConfirmScreenState createState() => _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState extends State<ResetPasswordConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          Uri.parse('${_apiService.baseUrl}/reset/${widget.uid}/${widget.token}/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'uid': widget.uid,
            'new_password': _newPasswordController.text,
            'confirm_password': _confirmPasswordController.text,
          }),
        );
        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Password reset successful!', style: GoogleFonts.outfit())),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          final error = jsonDecode(response.body)['error'];
          if (mounted) setState(() => _errorMessage = error);
        }
      } catch (e) {
        if (mounted) setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('New Password', style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFE0F7FA), Color(0xFFE1BEE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline_rounded, size: 48, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Set New Password",
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 32),
                    
                    CustomTextField(
                      controller: _newPasswordController,
                      hintText: 'New Password',
                      prefixIcon: Icons.lock_open_rounded,
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'New password is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      prefixIcon: Icons.lock_open_rounded,
                      obscureText: true,
                      validator: (value) {
                         if (value!.isEmpty) return 'Confirm password is required';
                         if (value != _newPasswordController.text) return 'Passwords do not match';
                         return null;
                      },
                    ),
                    
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(_errorMessage!, style: GoogleFonts.outfit(color: AppTheme.errorColor)),
                      ),
                      
                    const SizedBox(height: 32),
                    
                    GradientButton(
                      text: 'Reset Password',
                      onPressed: _resetPassword,
                      isLoading: _isLoading,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}