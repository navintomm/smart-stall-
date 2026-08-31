import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../auto_cleaning/domain/models/cleaning_profile.dart';
import '../../../vision/domain/models/dirt_severity.dart';

enum CleaningIntensity { normal, medium, hard }

class CleaningControlPanel extends ConsumerStatefulWidget {
  final bool isReady;

  const CleaningControlPanel({
    super.key,
    required this.isReady,
  });

  @override
  ConsumerState<CleaningControlPanel> createState() =>
      _CleaningControlPanelState();
}

class _CleaningControlPanelState extends ConsumerState<CleaningControlPanel> {
  CleaningIntensity _selectedIntensity = CleaningIntensity.normal;
  bool _isRunning = false;

  void _handleStart() async {
    if (!widget.isReady) return;
    setState(() => _isRunning = true);
    CleaningProfile profile;
    switch (_selectedIntensity) {
      case CleaningIntensity.normal:
        profile = const CleaningProfile(
          severity: DirtSeverity.light,
          waterVolumeMl: 100,
          pumpDurationMs: 2000,
          brushDurationMs: 5000,
          routineId: 'routine_normal',
        );
        break;
      case CleaningIntensity.medium:
        profile = const CleaningProfile(
          severity: DirtSeverity.moderate,
          waterVolumeMl: 250,
          pumpDurationMs: 4000,
          brushDurationMs: 8000,
          routineId: 'routine_medium',
        );
        break;
      case CleaningIntensity.hard:
        profile = const CleaningProfile(
          severity: DirtSeverity.severe,
          waterVolumeMl: 400,
          pumpDurationMs: 6000,
          brushDurationMs: 12000,
          routineId: 'routine_hard',
        );
        break;
    }
    final repo = ref.read(robotRepositoryProvider);
    await repo.startCleaningWithProfile(profile);
  }

  void _handlePause() async {
    final repo = ref.read(robotRepositoryProvider);
    await repo.pauseCleaning();
    setState(() => _isRunning = false);
  }

  void _handleStop() async {
    final repo = ref.read(robotRepositoryProvider);
    await repo.stopCleaning();
    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardGlass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Mode label ──
          Text(
            'CLEANING MODE',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Intensity Selectors ──
          Row(
            children: [
              Expanded(child: _buildIntensityButton(CleaningIntensity.normal, 'Normal', Icons.water_drop_outlined)),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: _buildIntensityButton(CleaningIntensity.medium, 'Medium', Icons.water_drop)),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: _buildIntensityButton(CleaningIntensity.hard, 'Hard', Icons.warning_amber_rounded)),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Action Buttons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.stop_rounded,
                color: AppColors.dangerRed,
                onPressed: _isRunning ? _handleStop : null,
                label: 'STOP',
              ),
              _buildActionButton(
                icon: Icons.pause_rounded,
                color: AppColors.warningOrange,
                onPressed: _isRunning ? _handlePause : null,
                label: 'PAUSE',
              ),
              _buildActionButton(
                icon: Icons.play_arrow_rounded,
                color: AppColors.successGreen,
                onPressed: (widget.isReady && !_isRunning) ? _handleStart : null,
                label: 'START',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityButton(
      CleaningIntensity intensity, String label, IconData icon) {
    final isSelected = _selectedIntensity == intensity;
    return GestureDetector(
      onTap: () {
        if (!_isRunning) setState(() => _selectedIntensity = intensity);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required String label,
  }) {
    final isDisabled = onPressed == null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDisabled
                  ? AppColors.borderLight.withOpacity(0.4)
                  : color.withOpacity(0.15),
              border: Border.all(
                color: isDisabled ? AppColors.borderLight : color.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 26,
              color: isDisabled ? AppColors.textMuted : color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDisabled ? AppColors.textMuted : color,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
