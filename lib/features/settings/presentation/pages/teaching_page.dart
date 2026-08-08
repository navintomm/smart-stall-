import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../features/manual_control/presentation/widgets/camera_placeholder.dart';
import '../../../../features/manual_control/presentation/widgets/control_pad.dart';
import '../../../../features/manual_control/presentation/widgets/servo_slider_card.dart';
import '../../../../features/manual_control/presentation/providers/manual_control_provider.dart';
import '../../../../shared/widgets/navigation/navigation_header.dart';
import '../providers/routine_recording_provider.dart';
import '../../domain/models/routine_recording_state.dart';

class TeachingPage extends ConsumerWidget {
  const TeachingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordState = ref.watch(routineRecordingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const NavigationHeader(
              title: 'Arm Teaching',
              icon: AppIcons.training,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info banner
                    _InfoBanner(),
                    const SizedBox(height: AppSpacing.lg),

                    // Camera preview
                    const SizedBox(
                      height: 200,
                      child: CameraPlaceholder(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Recording status
                    _RecordingStatusCard(state: recordState),
                    const SizedBox(height: AppSpacing.lg),

                    // Joystick / Control pad
                    _SectionLabel(label: 'Movement Control'),
                    const SizedBox(height: AppSpacing.sm),
                    const Center(child: ControlPad()),
                    const SizedBox(height: AppSpacing.lg),

                    // Servo sliders
                    _SectionLabel(label: 'Joint Control'),
                    const SizedBox(height: AppSpacing.sm),
                    _ServoSection(),
                    const SizedBox(height: AppSpacing.xl),

                    // Record / Stop buttons
                    _RecordingControls(state: recordState),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info Banner ──────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.informationCyan.withOpacity(0.08),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.informationCyan.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.info, color: AppColors.informationCyan, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Move the robot arm to your desired positions, then press Record to capture the motion sequence.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.informationCyan),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleLarge.copyWith(fontSize: 15),
    );
  }
}

// ─── Recording Status Card ────────────────────────────────────────────────────
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isRecording ? AppIcons.record : AppIcons.stopRecord,
            color: color,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRecording ? 'Recording…' : 'Recording complete',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: color, fontWeight: FontWeight.w700),
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

// ─── Servo Section ────────────────────────────────────────────────────────────
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

// ─── Recording Controls ───────────────────────────────────────────────────────
class _RecordingControls extends ConsumerWidget {
  final RoutineRecordingState state;
  const _RecordingControls({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(routineRecordingProvider.notifier);

    if (state.status == RecordingStatus.saving) {
      // Show save dialog trigger automatically
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSaveDialog(context, ref);
      });
    }

    return Row(
      children: [
        // Record button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isRecording ? null : notifier.startRecording,
            icon: const Icon(AppIcons.record, size: 18),
            label: const Text('Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: const StadiumBorder(),
              elevation: 0,
              disabledBackgroundColor: AppColors.borderLight,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Stop button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isRecording ? notifier.stopRecording : null,
            icon: const Icon(AppIcons.stopRecord, size: 18),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.text,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
        title: Row(
          children: [
            Icon(AppIcons.library, color: AppColors.primary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            const Text('Save Routine'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Give this routine a name so you can identify it in the Motion Library.',
              style: AppTextStyles.bodyMedium,
            ),
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
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
            child: Text('Discard',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.dangerRed)),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(routineRecordingProvider.notifier)
                  .saveAsRoutine(controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Routine saved to Motion Library'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: const StadiumBorder(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: const StadiumBorder(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
