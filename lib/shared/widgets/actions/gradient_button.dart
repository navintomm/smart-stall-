import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

/// Purpose: A high-emphasis gradient button.
/// Usage: The most important actions on a screen.
/// Parameters:
///   - [onPressed]: Callback when tapped.
///   - [text]: Button text.
/// Example:
/// `dart
/// GradientButton(onPressed: () {}, text: "Start Cleaning");
/// `
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const GradientButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mediumRadius,
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          boxShadow: AppShadows.glowShadow,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 48), // Touch target
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mediumRadius,
            ),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
