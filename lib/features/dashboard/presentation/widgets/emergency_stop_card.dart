import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';


class EmergencyStopCard extends StatelessWidget {
  const EmergencyStopCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.dangerRed.withOpacity(0.1),
          border: Border.all(color: AppColors.dangerRed.withOpacity(0.3), width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(100),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AppIcons.warning, color: AppColors.dangerRed, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'EMERGENCY STOP',
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.dangerRed, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
