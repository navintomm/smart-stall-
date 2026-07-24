import 'package:flutter/material.dart';
import '../foundation/glass_card.dart';
import '../../../core/theme/app_colors.dart';

/// Purpose: Displays a single data metric.
/// Usage: Use in dashboards to show stats like battery level.
/// Parameters:
///   - [title]: Metric name.
///   - [value]: Metric value.
/// Example:
/// `dart
/// MetricCard(title: 'Battery', value: '80%');
/// `
class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Metric  is ',
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

