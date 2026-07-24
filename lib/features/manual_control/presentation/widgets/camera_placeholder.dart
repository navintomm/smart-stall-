import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/status_chip.dart';

class CameraPlaceholder extends StatelessWidget {
  const CameraPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GlassCard(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(AppIcons.camera, size: 64, color: Colors.black26),
                    const SizedBox(height: AppSpacing.md),
                    Text('No Camera Connected', style: AppTextStyles.displayMedium.copyWith(color: Colors.black45)),
                  ],
                ),
              ),
              const Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: StatusChip(label: 'OFFLINE', color: AppColors.warningOrange),
              ),
              const Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: StatusChip(label: '0 FPS', color: Colors.black45),
              ),
              const Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                child: StatusChip(label: 'AI: INACTIVE', color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
