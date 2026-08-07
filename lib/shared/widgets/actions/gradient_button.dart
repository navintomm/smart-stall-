import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

import '../foundation/animated_scale_button.dart';

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
      child: AnimatedScaleButton(
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.extraLargeRadius,
            color: AppColors.secondary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 56), // Larger Touch target
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.extraLargeRadius,
              ),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
