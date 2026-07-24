import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Purpose: A themed circular progress indicator.
/// Usage: Loading states.
/// Parameters: None
/// Example:
/// `dart
/// CircularProgressGlass();
/// `
class CircularProgressGlass extends StatelessWidget {
  const CircularProgressGlass({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}


