import 'package:flutter/material.dart';
import '../foundation/glass_card.dart';
import '../../../core/theme/app_colors.dart';

/// Purpose: A prominent card that acts as a button.
/// Usage: Large interactive areas like 'Start Cleaning'.
/// Parameters:
///   - [title]: Card title.
///   - [icon]: Icon to display.
///   - [onTap]: Tap callback.
/// Example:
/// `dart
/// PrimaryActionCard(title: 'Start', icon: Icons.play_arrow, onTap: () {});
/// `
class PrimaryActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const PrimaryActionCard({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

