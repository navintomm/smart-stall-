import 'package:flutter/material.dart';
import '../../domain/models/network_metric.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class NetworkMetricCard extends StatelessWidget {
  final NetworkMetric metric;

  const NetworkMetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      animateEntrance: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              metric.value,
              style: AppTextStyles.displayMedium.copyWith(
                color: metric.isWarning ? AppColors.warningOrange : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(metric.name, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

