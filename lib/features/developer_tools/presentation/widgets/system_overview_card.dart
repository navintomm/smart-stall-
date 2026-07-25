import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

class SystemOverviewCard extends ConsumerWidget {
  const SystemOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      animateEntrance: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Overview', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _buildRow('App Version', '1.0.0-beta.1'),
          _buildRow('Protocol Version', '2.0'),
          _buildRow('Build Mode', 'Debug'),
          _buildRow('Active Repository', 'SimulationRobotRepository'),
          _buildRow('Connection State', 'Simulated (Connected)'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
