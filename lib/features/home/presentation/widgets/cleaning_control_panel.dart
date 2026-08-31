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
  ConsumerState<CleaningControlPanel> createState() => _CleaningControlPanelState();
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardGlass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CLEANING MODE',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Intensity Selectors
          Row(
            children: [
              Expanded(child: _buildIntensityButton(CleaningIntensity.normal, 'Normal', Icons.water_drop_outlined)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildIntensityButton(CleaningIntensity.medium, 'Medium', Icons.water_drop)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildIntensityButton(CleaningIntensity.hard, 'Hard', Icons.warning_amber_rounded)),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Action Buttons
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
          )
        ],
      ),
    );
  }

  Widget _buildIntensityButton(CleaningIntensity intensity, String label, IconData icon) {
    final isSelected = _selectedIntensity == intensity;
    return GestureDetector(
      onTap: () {
        if (!_isRunning) {
          setState(() => _selectedIntensity = intensity);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
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
              size: 28,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
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
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 36),
          style: IconButton.styleFrom(
            backgroundColor: isDisabled ? AppColors.borderLight.withOpacity(0.3) : color.withOpacity(0.15),
            foregroundColor: isDisabled ? Colors.white38 : color,
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDisabled ? Colors.white38 : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
