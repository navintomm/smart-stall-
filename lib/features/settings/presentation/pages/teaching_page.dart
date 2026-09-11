import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../features/manual_control/presentation/widgets/joystick_controller.dart';
import '../../../../features/manual_control/presentation/providers/manual_control_provider.dart';
import '../providers/trajectory_recording_provider.dart';
import '../../domain/models/trajectory_recording_state.dart';
import '../../../../core/providers/app_config_provider.dart';

class TeachingPage extends ConsumerStatefulWidget {
  const TeachingPage({super.key});

  @override
  ConsumerState<TeachingPage> createState() => _TeachingPageState();
}

class _TeachingPageState extends ConsumerState<TeachingPage> {
  double _speed = 0.5; // 0.0 – 1.0

  void _showSpeedDialog(BuildContext context, WidgetRef ref) {
    double tempSpeed = _speed;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Speed Control'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current speed: ${(tempSpeed * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodyMedium),
              Slider(
                value: tempSpeed,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                activeColor: AppColors.primary,
                onChanged: (v) => setDialogState(() => tempSpeed = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                setState(() => _speed = tempSpeed);
                ref.read(manualControlProvider.notifier).sendCommand('SET_SPEED:${(tempSpeed * 100).toStringAsFixed(0)}');
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndEffectorDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Effector Control'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.water_drop_rounded, color: AppColors.informationCyan),
              title: const Text('Spray ON'),
              onTap: () { ref.read(manualControlProvider.notifier).sendCommand('EFFECTOR_SPRAY_ON'); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop_outlined, color: AppColors.textSecondary),
              title: const Text('Spray OFF'),
              onTap: () { ref.read(manualControlProvider.notifier).sendCommand('EFFECTOR_SPRAY_OFF'); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.warningOrange),
              title: const Text('Brush ON'),
              onTap: () { ref.read(manualControlProvider.notifier).sendCommand('EFFECTOR_BRUSH_ON'); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.textSecondary),
              title: const Text('Brush OFF'),
              onTap: () { ref.read(manualControlProvider.notifier).sendCommand('EFFECTOR_BRUSH_OFF'); Navigator.pop(ctx); },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
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
              ref.read(trajectoryRecordingProvider.notifier).discardRecording();
              Navigator.pop(ctx);
            },
            child: Text('Discard', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.dangerRed)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(trajectoryRecordingProvider.notifier).saveAsRoutine(controller.text);
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

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(trajectoryRecordingProvider);

    // Trigger save dialog when recording stops
    if (recordState.status == RecordingStatus.saving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSaveDialog(context);
      });
    }

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
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isSimulation = ref.watch(appConfigProvider).isSimulationMode;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSimulation ? AppColors.warningOrange.withOpacity(0.2) : AppColors.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSimulation ? AppColors.warningOrange : AppColors.successGreen),
                    ),
                    child: Text(
                      isSimulation ? 'SIMULATION' : 'HARDWARE',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSimulation ? AppColors.warningOrange : AppColors.successGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── LEFT: Linear Motion (Up / Down) ──────────────────────────
              SizedBox(
                width: 80,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _SectionLabel(label: 'LINEAR'),
                      const SizedBox(height: AppSpacing.md),
                      _LinearButton(
                        icon: Icons.keyboard_arrow_up_rounded,
                        label: 'UP',
                        color: AppColors.primary,
                        onPressed: () => ref.read(manualControlProvider.notifier).sendCommand('LINEAR_UP'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _LinearButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        label: 'DOWN',
                        color: AppColors.warningOrange,
                        onPressed: () => ref.read(manualControlProvider.notifier).sendCommand('LINEAR_DOWN'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // ── CENTER: Joystick ──────────────────────────────────────────
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Fit joystick to available height minus label and status card
                      final maxJoy = (constraints.maxHeight - 80).clamp(100.0, 200.0);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _SectionLabel(label: 'MOVEMENT CONTROL'),
                          const SizedBox(height: AppSpacing.sm),
                          JoystickController(
                            size: maxJoy,
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
                          const SizedBox(height: AppSpacing.xs),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                            child: _RecordingStatusCard(state: recordState),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // ── RIGHT: Action Panel ───────────────────────────────────────
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Speed Control
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.speed_rounded,
                        label: 'Speed Control',
                        color: AppColors.informationCyan,
                        onTap: () => _showSpeedDialog(context, ref),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // End Effector Control
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.precision_manufacturing_rounded,
                        label: 'End Effector',
                        color: const Color(0xFF6C63FF),
                        onTap: () => _showEndEffectorDialog(context, ref),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Record
                    Expanded(
                      child: _ActionCard(
                        icon: AppIcons.record,
                        label: 'Record',
                        color: AppColors.dangerRed,
                        isDisabled: recordState.isRecording,
                        onTap: recordState.isRecording
                            ? null
                            : () => ref.read(trajectoryRecordingProvider.notifier).startRecording(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Stop
                    Expanded(
                      child: _ActionCard(
                        icon: AppIcons.stopRecord,
                        label: 'Stop',
                        color: AppColors.text,
                        isDisabled: !recordState.isRecording,
                        onTap: !recordState.isRecording
                            ? null
                            : () => ref.read(trajectoryRecordingProvider.notifier).stopRecording(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Go to Library
                    Expanded(
                      child: _ActionCard(
                        icon: AppIcons.library,
                        label: 'Go to Library',
                        color: AppColors.primary,
                        onTap: () => context.push(AppRoutes.motionLibrary),
                      ),
                    ),
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
  final TrajectoryRecordingState state;
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

    final servo1 = state.samples.isNotEmpty ? state.samples.last.servo1Angle : 0.0;
    final servo2 = state.samples.isNotEmpty ? state.samples.last.servo2Angle : 0.0;

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
                  '${state.samples.length} samples · $_elapsedFormatted',
                  style: AppTextStyles.bodySmall,
                ),
                if (isRecording && state.samples.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'S1: ${servo1.toStringAsFixed(1)}° | S2: ${servo2.toStringAsFixed(1)}°',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinearButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _LinearButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled ? AppColors.textMuted : color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.borderLight.withOpacity(0.35)
                : effectiveColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDisabled
                  ? AppColors.borderLight
                  : effectiveColor.withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: effectiveColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
