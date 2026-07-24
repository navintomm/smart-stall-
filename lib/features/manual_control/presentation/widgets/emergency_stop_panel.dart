import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class EmergencyStopPanel extends StatelessWidget {
  const EmergencyStopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Material(
        color: AppColors.dangerRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('EMERGENCY STOP'),
                content: const Text('Are you sure you want to halt all robot operations immediately?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('STOP ROBOT', style: TextStyle(color: AppColors.dangerRed))),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.dangerRed, width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.warning, color: AppColors.dangerRed, size: 48),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'EMERGENCY STOP',
                  style: AppTextStyles.displayLarge.copyWith(color: AppColors.dangerRed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
