import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/status_indicator.dart';
import '../../../../shared/widgets/feedback/shimmer_loader.dart';
import '../../../../shared/widgets/display/animated_value_text.dart';
import '../../../../shared/widgets/foundation/floating_animation.dart';
import '../../presentation/providers/dashboard_provider.dart';

class RobotStatusCard extends ConsumerWidget {
  const RobotStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final status = state.status;
    
    if (status == null) {
      return const GlassCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerLoader(width: 150, height: 100),
                  ShimmerLoader(width: 80, height: 30, borderRadius: BorderRadius.all(Radius.circular(16))),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              ShimmerLoader(width: double.infinity, height: 60),
            ],
          ),
        ),
      );
    }

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
                    FloatingAnimation(
                      child: Image.asset('assets/images/robot_render.png', height: 100),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SmartStall', style: AppTextStyles.bodyMedium),
                        Text(status.id, style: AppTextStyles.displayMedium),
                      ],
                    ),
                  ],
                ),
                StatusIndicator(color: status.state == 'ACTIVE' ? AppColors.successGreen : AppColors.warningOrange),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusItem(
                    label: 'Battery', 
                    value: "${status.batteryLevel}%",
                    numericValue: status.batteryLevel.toDouble(),
                    suffix: '%',
                  ),
                  _StatusItem(label: 'Mode', value: status.state),
                  const _StatusItem(label: 'Last Sync', value: 'Just now'),
                ],
              ),
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
  final double? numericValue;
  final String suffix;
  
  const _StatusItem({
    required this.label, 
    required this.value,
    this.numericValue,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        numericValue != null
            ? AnimatedValueText(
                value: numericValue!,
                suffix: suffix,
                style: AppTextStyles.titleLarge,
              )
            : Text(value, style: AppTextStyles.titleLarge),
      ],
    );
  }
}

