import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../auto_cleaning/domain/models/cleaning_profile.dart';
import '../../../vision/domain/models/dirt_severity.dart';
import 'routine_selector_card.dart';

class CleaningControlPanel extends ConsumerStatefulWidget {
  final bool isReady;
  
  // Passed down for blocking-reason strip inside RoutineSelectorCard
  final bool isConnected;
  final bool isCalibrated;
  final bool isEStop;
  final bool markerDetected;
  final bool alignmentReady;
  final bool cameraAvailable;

  const CleaningControlPanel({
    super.key,
    required this.isReady,
    this.isConnected = true,
    this.isCalibrated = true,
    this.isEStop = false,
    this.markerDetected = true,
    this.alignmentReady = true,
    this.cameraAvailable = true,
  });

  @override
  ConsumerState<CleaningControlPanel> createState() =>
      _CleaningControlPanelState();
}

class _CleaningControlPanelState extends ConsumerState<CleaningControlPanel> {
  bool _isRunning = false;

  void _handleStart() async {
    if (!widget.isReady) return;
    setState(() => _isRunning = true);
    
    // Defaulting to a standard profile since AI dirt detection is shelved.
    const profile = CleaningProfile(
      severity: DirtSeverity.light,
      waterVolumeMl: 250,
      pumpDurationMs: 4000,
      brushDurationMs: 8000,
      routineId: 'selected_routine', 
    );
    
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Routine Selector ──
        Expanded(
          child: RoutineSelectorCard(
            isReady: widget.isReady,
            isConnected: widget.isConnected,
            isCalibrated: widget.isCalibrated,
            isEStop: widget.isEStop,
            markerDetected: widget.markerDetected,
            alignmentReady: widget.alignmentReady,
            cameraAvailable: widget.cameraAvailable,
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),

        // ── Action Buttons ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardGlass,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
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
        ),
      ],
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
            width: 56,
            height: 56,
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
              size: 28,
              color: isDisabled ? AppColors.textMuted : color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDisabled ? AppColors.textMuted : color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
