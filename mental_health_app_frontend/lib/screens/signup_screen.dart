import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'guardian_details_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _gender;
  PlatformFile? _medicalHistory;

  Future<void> _pickMedicalHistory() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => _medicalHistory = result.files.first);
    }
  }

  void _submitUserDetails() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuardianDetailsScreen(
            userData: {
              'name': _nameController.text,
              'age': _ageController.text,
              'phone_number': _phoneController.text,
              'email': _emailController.text,
              'password': _passwordController.text,
              'confirm_password': _confirmPasswordController.text,
              'gender': _gender,
              'medical_history': _medicalHistory,
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 🌸 Background Decoration
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/abstract_shapes.png', 
                width: 300,
                color: AppTheme.mintGreen.withOpacity(0.3),
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'Create Account',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Start your journey with us',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Name
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Age & Gender Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _ageController,
                            hintText: 'Age',
                            prefixIcon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                              boxShadow: [
                                 BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                 )
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _gender,
                                hint: Text('Gender', style: GoogleFonts.outfit(color: AppTheme.textLight, fontSize: 15)),
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textLight),
                                items: ['Male', 'Female', 'Other'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: GoogleFonts.outfit(color: AppTheme.textDark)),
                                  );
                                }).toList(),
                                onChanged: (newValue) => setState(() => _gender = newValue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    CustomTextField(
                      controller: _phoneController,
                      hintText: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (value != _passwordController.text) return 'Mismatch';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Medical History Button
                    OutlinedButton.icon(
                      onPressed: _pickMedicalHistory,
                      icon: Icon(
                        _medicalHistory == null ? Icons.upload_file_rounded : Icons.check_circle_rounded,
                        color: _medicalHistory == null ? AppTheme.primaryColor : Colors.green,
                      ),
                      label: Text(
                        _medicalHistory == null ? 'Upload Medical History (Optional)' : 'File Selected: ${_medicalHistory!.name}',
                        style: GoogleFonts.outfit(
                          color: _medicalHistory == null ? AppTheme.primaryColor : AppTheme.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.inputRadius)),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit
                    GradientButton(
                      text: 'Continue',
                      onPressed: _submitUserDetails,
                      icon: Icons.arrow_forward_rounded,
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}