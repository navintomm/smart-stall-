import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_radius.dart';

class EmergencyStopPanel extends StatelessWidget {
  const EmergencyStopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppColors.dangerRed,
        boxShadow: AppShadows.glowingRed,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.cardGlass,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
                title: const Text('EMERGENCY STOP'),
                content: const Text('Are you sure you want to halt all robot operations immediately?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('STOP ROBOT', style: TextStyle(color: AppColors.dangerRed))),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.warning, color: Colors.white, size: 36),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'EMERGENCY STOP',
                  style: AppTextStyles.displayMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
