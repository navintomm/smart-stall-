import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class EmergencyStopCard extends StatelessWidget {
  const EmergencyStopCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.warning, color: AppColors.dangerRed, size: 32),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'EMERGENCY STOP',
                  style: AppTextStyles.displayMedium.copyWith(color: AppColors.dangerRed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
