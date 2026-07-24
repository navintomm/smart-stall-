import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/status_indicator.dart';

class RobotStatusCard extends StatelessWidget {
  const RobotStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.robot, size: 32, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('AlphaBot-01', style: AppTextStyles.displayMedium),
                  ],
                ),
                const StatusIndicator(color: AppColors.successGreen),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusItem(label: 'Battery', value: '87%'),
                _StatusItem(label: 'Mode', value: 'Idle'),
                _StatusItem(label: 'Last Sync', value: 'Just now'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatusItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}


