import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/status_indicator.dart';
import '../../presentation/providers/dashboard_provider.dart';

class RobotStatusCard extends ConsumerWidget {
  const RobotStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final status = state.status;
    
    if (status == null) return const CircularProgressIndicator();

    return GlassCard(
      animateEntrance: true,
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
                    Text(status.id, style: AppTextStyles.displayLarge),
                  ],
                ),
                StatusIndicator(color: status.state == 'ACTIVE' ? AppColors.successGreen : AppColors.warningOrange),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusItem(label: 'Battery', value: "${status.batteryLevel}%"),
                _StatusItem(label: 'Mode', value: status.state),
                const _StatusItem(label: 'Last Sync', value: 'Just now'),
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
        Text(value, style: AppTextStyles.titleLarge),
      ],
    );
  }
}

