import 'package:flutter/material.dart';
import '../../domain/models/robot_device.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import 'signal_strength_indicator.dart';

class RobotCard extends StatelessWidget {
  final RobotDevice robot;

  const RobotCard({super.key, required this.robot});

  @override
  Widget build(BuildContext context) {
    final isOnline = robot.status == 'Online';
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.successGreen : Colors.black26,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(robot.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  Text("${robot.type} • ${robot.status}", style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
                ],
              ),
            ),
            SignalStrengthIndicator(quality: robot.signalQuality),
            const SizedBox(width: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isOnline ? AppColors.primary : Colors.black12,
                foregroundColor: isOnline ? Colors.white : Colors.black54,
                elevation: 0,
              ),
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
