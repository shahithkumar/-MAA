import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Changed to nullable
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;
  final List<Color>? colors;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.padding,
    this.icon,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if button is disabled
    final isDisabled = onPressed == null || isLoading;

    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        // Use grey gradient if disabled
        gradient: isDisabled 
            ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
            : LinearGradient(
                colors: colors ?? [AppTheme.primaryColor, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        boxShadow: isDisabled
            ? [] // No shadow if disabled
            : [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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
