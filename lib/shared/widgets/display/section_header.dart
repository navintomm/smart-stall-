import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// Purpose: A reusable header for sections across the app.
/// Usage: Use at the top of a list or section grouping.
/// Parameters:
///   - [title]: The title of the section.
/// Example:
/// `dart
/// SectionHeader(title: "Settings");
/// `
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Section ',
      child: Text(
        title,
        style: AppTextStyles.displayLarge.copyWith(fontSize: 20), // Scalable
      ),
    );
  }
}
