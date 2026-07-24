import 'package:flutter/material.dart';
import '../../domain/models/sensor_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class SensorStatusCard extends StatelessWidget {
  final SensorStatus sensor;

  const SensorStatusCard({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(sensor.value, style: AppTextStyles.displayMedium.copyWith(color: sensor.isWarning ? AppColors.warningOrange : AppColors.primary)),
            const SizedBox(height: AppSpacing.xs),
            Text(sensor.name, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
