import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class GuardianDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const GuardianDetailsScreen({super.key, required this.userData});

  @override
  _GuardianDetailsScreenState createState() => _GuardianDetailsScreenState();
}

class _GuardianDetailsScreenState extends State<GuardianDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });
      
      try {
        await _apiService.register(
          name: widget.userData['name'],
          age: widget.userData['age'],
          phoneNumber: widget.userData['phone_number'],
          email: widget.userData['email'],
          password: widget.userData['password'],
          confirmPassword: widget.userData['confirm_password'],
          gender: widget.userData['gender'],
          guardianName: _nameController.text,
          guardianRelationship: _relationshipController.text,
          guardianPhoneNumber: _phoneController.text,
          guardianEmail: _emailController.text,
          medicalHistory: widget.userData['medical_history'] != null
              ? widget.userData['medical_history'] as PlatformFile?
              : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please log in.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
           setState(() {
             _errorMessage = e.toString().replaceFirst('Exception: ', '');
             _isLoading = false;
           });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Guardian Details', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
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
            colors: [Color(0xFFE0F7FA), Color(0xFFF3E5F5)], // Soft Cyan to Soft Lavender
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   GlassCard(
                     padding: const EdgeInsets.all(32),
                     child: Form(
                       key: _formKey,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                           Text(
                             "Who should we contact in an emergency?",
                             style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textLight),
                             textAlign: TextAlign.center,
                           ),
                           const SizedBox(height: 32),
                           
                           CustomTextField(
                             controller: _nameController,
                             hintText: 'Guardian Name',
                             prefixIcon: Icons.person_outline,
                             validator: (value) => value!.isEmpty ? 'Required' : null,
                           ),
                           const SizedBox(height: 16),
                           CustomTextField(
                             controller: _relationshipController,
                             hintText: 'Relationship',
                             prefixIcon: Icons.people_outline,
                             validator: (value) => value!.isEmpty ? 'Required' : null,
                           ),
                           const SizedBox(height: 16),
                           CustomTextField(
                             controller: _phoneController,
                             hintText: 'Phone Number',
                             prefixIcon: Icons.phone_outlined,
                             keyboardType: TextInputType.phone,
                             validator: (value) => value!.isEmpty ? 'Required' : null,
                           ),
                           const SizedBox(height: 16),
                           CustomTextField(
                             controller: _emailController,
                             hintText: 'Email',
                             prefixIcon: Icons.email_outlined,
                             keyboardType: TextInputType.emailAddress,
                             validator: (value) {
                               if (value!.isEmpty) return 'Required';
                               if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid email';
                               return null;
                             },
                           ),
                           
                           if (widget.userData['medical_history'] != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 20),
                               child: Container(
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withOpacity(0.5),
                                   borderRadius: BorderRadius.circular(12),
                                   border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                                 ),
                                 child: Row(
                                   children: [
                                     const Icon(Icons.attach_file, color: AppTheme.primaryColor),
                                     const SizedBox(width: 8),
                                     Expanded(
                                       child: Text(
                                         'Medical History: ${(widget.userData['medical_history'] as PlatformFile).name}',
                                         style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textDark),
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                     ),
                                     const Icon(Icons.check_circle, color: Colors.green),
                                   ],
                                 ),
                               ),
                             ),
                           
                           if (_errorMessage != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 20),
                               child: Text(_errorMessage!, style: GoogleFonts.outfit(color: AppTheme.errorColor), textAlign: TextAlign.center),
                             ),
                           
                           const SizedBox(height: 32),
                           
                           GradientButton(
                             text: 'Complete Registration',
                             onPressed: _register,
                             isLoading: _isLoading,
                           ),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}