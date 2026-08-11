import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../features/manual_control/presentation/widgets/camera_placeholder.dart';
import '../../../../features/manual_control/presentation/widgets/joystick_controller.dart';
import '../../../../features/manual_control/presentation/widgets/servo_slider_card.dart';
import '../../../../features/manual_control/presentation/providers/manual_control_provider.dart';
import '../providers/routine_recording_provider.dart';
import '../../domain/models/routine_recording_state.dart';

class TeachingPage extends ConsumerWidget {
  const TeachingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordState = ref.watch(routineRecordingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Arm Teaching',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── LEFT ZONE: Status & Camera ──────────────────────────────
              Expanded(
                flex: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InfoBanner(),
                    const SizedBox(height: AppSpacing.md),
                    const Expanded(
                      child: CameraPlaceholder(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RecordingStatusCard(state: recordState),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),

              // ── CENTER ZONE: Joystick ───────────────────────────────────
              Expanded(
                flex: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _SectionLabel(label: 'Movement Control'),
                      const SizedBox(height: AppSpacing.md),
                      JoystickController(
                        size: 180,
                        onDirectionChanged: (offset) {
                          final notifier = ref.read(manualControlProvider.notifier);
                          if (offset.dx.abs() < 0.1 && offset.dy.abs() < 0.1) {
                            notifier.sendCommand('STOP');
                          } else if (offset.dy.abs() > offset.dx.abs()) {
                            notifier.sendCommand(offset.dy < 0 ? 'MOVE_FORWARD' : 'MOVE_BACKWARD');
                          } else {
                            notifier.sendCommand(offset.dx > 0 ? 'TURN_RIGHT' : 'TURN_LEFT');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),

              // ── RIGHT ZONE: Joints & Controls ───────────────────────────
              Expanded(
                flex: 35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionLabel(label: 'Joint Control'),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderLight, width: 1.5),
                        ),
                        child: ListView(
                          children: [
                            _ServoSection(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _RecordingControls(state: recordState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.informationCyan.withOpacity(0.08),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.informationCyan.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.info, color: AppColors.informationCyan, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Move the robot arm to your desired positions, then press Record to capture.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.informationCyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}

class _RecordingStatusCard extends StatelessWidget {
  final RoutineRecordingState state;
  const _RecordingStatusCard({required this.state});

  String get _elapsedFormatted {
    final s = (state.elapsedMs / 1000).toStringAsFixed(1);
    return '$s s';
  }

  @override
  Widget build(BuildContext context) {
    if (state.isIdle) return const SizedBox.shrink();
    final isRecording = state.isRecording;
    final color = isRecording ? AppColors.dangerRed : AppColors.warningOrange;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(isRecording ? AppIcons.record : AppIcons.stopRecord, color: color, size: 18),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRecording ? 'Recording…' : 'Recording complete',
                  style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${state.frames.length} frames · $_elapsedFormatted',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServoSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servos = ref.watch(manualControlProvider).servos;
    return Column(
      children: servos
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ServoSliderCard(servo: s),
              ))
          .toList(),
    );
  }
}

class _RecordingControls extends ConsumerWidget {
  final RoutineRecordingState state;
  const _RecordingControls({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(routineRecordingProvider.notifier);

    if (state.status == RecordingStatus.saving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSaveDialog(context, ref);
      });
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isRecording ? null : notifier.startRecording,
            icon: const Icon(AppIcons.record, size: 18),
            label: const Text('Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: const StadiumBorder(),
              elevation: 0,
              disabledBackgroundColor: AppColors.borderLight,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isRecording ? notifier.stopRecording : null,
            icon: const Icon(AppIcons.stopRecord, size: 18),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.text,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: const StadiumBorder(),
              elevation: 0,
              disabledBackgroundColor: AppColors.borderLight,
            ),
          ),
        ),
      ],
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        title: const Row(
          children: [
            Icon(AppIcons.library, color: AppColors.primary, size: 22),
            SizedBox(width: AppSpacing.sm),
            Text('Save Routine'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Give this routine a name so you can identify it.', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Full Stall Clean',
                hintStyle: AppTextStyles.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(routineRecordingProvider.notifier).discardRecording();
              Navigator.pop(ctx);
            },
            child: Text('Discard', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.dangerRed)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(routineRecordingProvider.notifier).saveAsRoutine(controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Routine saved'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: StadiumBorder(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
