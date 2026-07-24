import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';

/// Purpose: Displays a compact status indicator pill.
/// Usage: Show active/inactive or severity levels.
/// Parameters:
///   - [label]: Text to display.
///   - [color]: Base color of the chip.
/// Example:
/// `dart
/// StatusChip(label: 'Active', color: AppColors.successGreen);
/// `
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status ',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: AppRadius.extraLargeRadius,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
