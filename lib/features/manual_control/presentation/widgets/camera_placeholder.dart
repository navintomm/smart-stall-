import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/status_chip.dart';
import '../../../../shared/widgets/feedback/status_indicator.dart';

class CameraPlaceholder extends StatelessWidget {
  const CameraPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // AppRadius.largeRadius
          child: Container(
            color: Colors.black.withOpacity(0.9), // Dark premium background
            child: Stack(
              children: [
                // Focus Reticle
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                // Camera grid lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(width: 1, color: Colors.white.withOpacity(0.05)),
                    Container(width: 1, color: Colors.white.withOpacity(0.05)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(height: 1, color: Colors.white.withOpacity(0.05)),
                    Container(height: 1, color: Colors.white.withOpacity(0.05)),
                  ],
                ),
                // Top Left: LIVE indicator
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const StatusIndicator(color: AppColors.dangerRed),
                        const SizedBox(width: AppSpacing.sm),
                        Text('LIVE', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Top Right: FPS
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: StatusChip(label: '30 FPS', color: Colors.white.withOpacity(0.2)),
                ),
                // Bottom Control Overlay
                Positioned(
                  bottom: AppSpacing.md,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.camera, color: Colors.white.withOpacity(0.8), size: 20),
                          const SizedBox(width: AppSpacing.md),
                          Text('AI ALIGNMENT ACTIVE', style: AppTextStyles.bodySmall.copyWith(color: AppColors.informationCyan, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
