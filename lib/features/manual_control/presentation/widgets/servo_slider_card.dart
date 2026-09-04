import 'package:flutter/material.dart';
import '../../domain/models/servo_control.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class ServoSliderCard extends StatelessWidget {
  final ServoControl servo;

  const ServoSliderCard({super.key, required this.servo});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(servo.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text("${servo.currentAngle.toStringAsFixed(1)}°", style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
              ],
            ),
            SizedBox(
              height: 24,
              child: Slider(
                value: servo.currentAngle,
                min: servo.minAngle,
                max: servo.maxAngle,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.2),
                onChanged: (val) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
