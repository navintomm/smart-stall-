import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_shadows.dart';

/// HUD overlay displayed on top of the live camera feed on the Home screen.
/// Shows: Marker ID, Distance, Alignment Score, Camera Status, Robot Status.
class HomeHudOverlay extends StatelessWidget {
  final int? markerId;
  final String? semanticName;
  final String distanceText;
  final double alignmentScore; // 0.0 – 1.0
  final String cameraStatus;
  final String robotStatus;
  final bool isEStop;
  final bool isConnected;

  const HomeHudOverlay({
    super.key,
    required this.markerId,
    this.semanticName,
    required this.distanceText,
    required this.alignmentScore,
    required this.cameraStatus,
    required this.robotStatus,
    this.isEStop = false,
    this.isConnected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left: Camera Status + Robot Status
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusPill(
                label: 'CAM',
                value: cameraStatus,
                color: cameraStatus == 'Live' ? AppColors.successGreen : AppColors.warningOrange,
              ),
              const SizedBox(height: AppSpacing.xs),
              _StatusPill(
                label: 'ROBOT',
                value: isEStop ? 'E-STOP' : robotStatus,
                color: isEStop
                    ? AppColors.dangerRed
                    : isConnected
                        ? AppColors.successGreen
                        : AppColors.warningOrange,
              ),
            ],
          ),
        ),

        // Centre safety warning overlay — only shown for Emergency Stop
        if (isEStop)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardGlass.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.dangerRed,
                    width: 2,
                  ),
                  boxShadow: AppShadows.glowingRed,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emergency_rounded,
                      color: AppColors.dangerRed,
                      size: 28,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'EMERGENCY STOP',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.dangerRed,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Top-right: Alignment Score
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: _AlignmentBadge(score: alignmentScore),
        ),

        // Bottom centre: Marker HUD card
        Positioned(
          bottom: AppSpacing.xl,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardGlass.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: markerId != null
                    ? AppColors.successGreen.withOpacity(0.5)
                    : AppColors.borderLight,
                width: 1,
              ),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Marker ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MARKER ID',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      markerId != null ? '#$markerId' : '—',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.text, fontSize: 22),
                    ),
                    if (semanticName != null && markerId != null)
                      Text(
                        semanticName!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary, fontSize: 10),
                      ),
                  ],
                ),

                // Divider
                Container(width: 1, height: 36, color: AppColors.borderLight),

                // Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'DISTANCE',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      distanceText,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: markerId != null
                            ? AppColors.successGreen
                            : AppColors.textSecondary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                // Divider
                Container(width: 1, height: 36, color: AppColors.borderLight),

                // Alignment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ALIGNMENT',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(alignmentScore * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: alignmentScore >= 0.95
                            ? AppColors.successGreen
                            : AppColors.warningOrange,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardGlass.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.text, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AlignmentBadge extends StatelessWidget {
  final double score;
  const _AlignmentBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final isGood = score >= 0.95;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardGlass.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? AppColors.successGreen.withOpacity(0.5) : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGood ? Icons.check_circle_rounded : Icons.adjust_rounded,
            color: isGood ? AppColors.successGreen : AppColors.warningOrange,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            '${(score * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.bodySmall.copyWith(
              color: isGood ? AppColors.successGreen : AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
