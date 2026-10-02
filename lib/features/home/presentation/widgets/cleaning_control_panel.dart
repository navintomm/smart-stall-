import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../auto_cleaning/domain/models/cleaning_profile.dart';
import '../../../vision/domain/models/dirt_severity.dart';
import '../../../settings/domain/models/routine.dart';
import '../../../settings/presentation/providers/motion_library_provider.dart';
import '../../../auto_cleaning/presentation/providers/routine_playback_provider.dart';
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
  final int? markerId;

  const CleaningControlPanel({
    super.key,
    required this.isReady,
    this.isConnected = true,
    this.isCalibrated = true,
    this.isEStop = false,
    this.markerDetected = true,
    this.alignmentReady = true,
    this.cameraAvailable = true,
    this.markerId,
  });

  @override
  ConsumerState<CleaningControlPanel> createState() =>
      _CleaningControlPanelState();
}

class _CleaningControlPanelState extends ConsumerState<CleaningControlPanel> {
  String? _selectedRoutineId;

  // Removed didUpdateWidget auto-pause logic, because playing back a motion
  // physically moves the arm, which naturally breaks the camera's alignment
  // with the marker, causing an immediate unwanted pause.

  void _handleStart() async {
    if (!widget.isReady) return;
    if (_selectedRoutineId == null) return;
    
    final libraryState = ref.read(motionLibraryProvider);
    Routine? routine;
    for (final r in libraryState.routines) {
      if (r.id == _selectedRoutineId) {
        routine = r;
        break;
      }
    }

    if (routine != null) {
      ref.read(routinePlaybackProvider.notifier).start(routine);
    }
    
    // Defaulting to a standard profile since AI dirt detection is shelved.
    final profile = CleaningProfile(
      severity: DirtSeverity.light,
      waterVolumeMl: 250,
      pumpDurationMs: 4000,
      brushDurationMs: 8000,
      routineId: _selectedRoutineId!, 
    );
    
    final repo = ref.read(robotRepositoryProvider);
    await repo.startCleaningWithProfile(profile);
  }

  void _handlePause() async {
    ref.read(routinePlaybackProvider.notifier).pause();
    final repo = ref.read(robotRepositoryProvider);
    await repo.pauseCleaning();
  }

  void _handleStop() async {
    ref.read(routinePlaybackProvider.notifier).stop();
    final repo = ref.read(robotRepositoryProvider);
    await repo.stopCleaning();
  }

  void _handleResume() async {
    ref.read(routinePlaybackProvider.notifier).resume();
    final repo = ref.read(robotRepositoryProvider);
    await repo.resumeCleaning();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(motionLibraryProvider);
    final routines = libraryState.routines;
    final playbackState = ref.watch(routinePlaybackProvider);
    final isRunning = playbackState.status == PlaybackStatus.playing;

    // Filter routines by marker ID to ensure selection stays valid
    final availableRoutines = routines.where((r) => 
        r.markerId == widget.markerId || r.markerId == null
    ).toList();

    // 1. Auto-select exact match ONLY if alignment is ready (distance == 0)
    if (widget.alignmentReady && widget.markerId != null) {
      final exactMatches = availableRoutines.where((r) => r.markerId == widget.markerId).toList();
      if (exactMatches.isNotEmpty && _selectedRoutineId != exactMatches.first.id) {
        _selectedRoutineId = exactMatches.first.id;
      }
    }

    // 2. Initial default fallback
    if (_selectedRoutineId == null && libraryState.defaultRoutineId != null) {
      if (availableRoutines.any((r) => r.id == libraryState.defaultRoutineId)) {
        _selectedRoutineId = libraryState.defaultRoutineId;
      }
    }
    
    // 3. Invalid selection fallback
    if (_selectedRoutineId != null &&
        availableRoutines.every((r) => r.id != _selectedRoutineId)) {
      _selectedRoutineId = availableRoutines.isEmpty ? null : availableRoutines.first.id;
    }

    final isStartEnabled = widget.isReady && !isRunning && _selectedRoutineId != null;
    final isPauseEnabled = isRunning;
    final canResume = widget.isReady && playbackState.status == PlaybackStatus.paused;
    final isStopEnabled = playbackState.status != PlaybackStatus.idle && playbackState.status != PlaybackStatus.completed;

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
            markerId: widget.markerId,
            selectedRoutineId: _selectedRoutineId,
            onRoutineChanged: (id) {
              if (id != null) {
                setState(() => _selectedRoutineId = id);
              }
            },
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
                onPressed: isStopEnabled ? _handleStop : null,
                label: 'STOP',
              ),
              _buildActionButton(
                icon: Icons.pause_rounded,
                color: AppColors.warningOrange,
                onPressed: isPauseEnabled ? _handlePause : null,
                label: 'PAUSE',
              ),
              _buildActionButton(
                icon: Icons.play_arrow_rounded,
                color: AppColors.successGreen,
                onPressed: isStartEnabled ? _handleStart : (canResume ? _handleResume : null),
                label: playbackState.status == PlaybackStatus.paused ? 'RESUME' : 'START',
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
