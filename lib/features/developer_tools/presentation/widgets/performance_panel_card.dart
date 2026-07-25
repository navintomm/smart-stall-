import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

class PerformancePanelCard extends ConsumerWidget {
  const PerformancePanelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      animateEntrance: true,
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Metrics (Simulated)', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('FPS', '60.0'),
              _buildMetric('Memory', '142 MB'),
              _buildMetric('Latency', '12 ms'),
              _buildMetric('Providers', '24'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.displayMedium),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
