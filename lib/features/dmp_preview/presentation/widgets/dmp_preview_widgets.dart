import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../domain/models/dmp_joint_metrics.dart';
import '../../domain/models/dmp_result.dart';
import '../../domain/services/dmp_validator.dart';
import '../../domain/models/trajectory_streaming_state.dart';
import '../providers/dmp_preview_provider.dart';
import '../providers/dmp_streamer_provider.dart';

/// Playback controls bar: Play/Pause, Restart, Speed selector, View mode toggle.
class PlaybackControlsBar extends ConsumerWidget {
  const PlaybackControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dmpPreviewProvider);
    final notifier = ref.read(dmpPreviewProvider.notifier);
    final result = state.result;
    if (result == null) return const SizedBox.shrink();

    final isPlaying = state.playbackStatus == PlaybackStatus.playing;
    final durationSec = result.durationSeconds;
    final elapsed = (state.playbackProgress * durationSec).clamp(0.0, durationSec);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timeline scrubber
          Row(
            children: [
              Text(_fmt(elapsed), style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.borderLight,
                    overlayColor: AppColors.primary.withOpacity(0.15),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: state.playbackProgress,
                    onChanged: (v) {
                      notifier.pause();
                      notifier.updateProgress(v);
                    },
                    onChangeEnd: (_) {},
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(_fmt(durationSec), style: AppTextStyles.bodySmall),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Control buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Speed selector
              _SpeedSelector(
                currentSpeed: state.playbackSpeed,
                onSelect: notifier.setPlaybackSpeed,
              ),

              // Play / Pause / Restart
              Row(
                children: [
                  _IconBtn(
                    icon: Icons.replay_rounded,
                    onTap: notifier.restart,
                    tooltip: 'Restart',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  GestureDetector(
                    onTap: isPlaying ? notifier.pause : notifier.play,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              // Trail toggle
              Row(
                children: [
                  Text('Trail', style: AppTextStyles.bodySmall),
                  const SizedBox(width: 4),
                  Switch.adaptive(
                    value: state.showTrail,
                    onChanged: (_) => notifier.toggleTrail(),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toStringAsFixed(1).padLeft(4, '0');
    return '$m:$s';
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _IconBtn({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.textSecondary, size: 22),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSelect;
  const _SpeedSelector({required this.currentSpeed, required this.onSelect});

  static const speeds = [0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: speeds.map((s) {
        final selected = (s - currentSpeed).abs() < 0.01;
        return GestureDetector(
          onTap: () => onSelect(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.borderLight,
              ),
            ),
            child: Text(
              '${s}x',
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── View Mode Toggle ──────────────────────────────────────────────────────────
class ViewModeToggle extends ConsumerWidget {
  const ViewModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(dmpPreviewProvider).viewMode;
    final notifier = ref.read(dmpPreviewProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TrajectoryViewMode.values.map((m) {
          final selected = m == mode;
          final label = switch (m) {
            TrajectoryViewMode.original => 'Original',
            TrajectoryViewMode.dmp => 'DMP',
            TrajectoryViewMode.compare => 'Compare',
          };
          return GestureDetector(
            onTap: () => notifier.setViewMode(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Metrics Panel ─────────────────────────────────────────────────────────────
class MetricsPanel extends StatelessWidget {
  final DmpResult result;
  const MetricsPanel({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Error Metrics'),
          const SizedBox(height: AppSpacing.sm),
          _JointMetricsCard(metrics: result.servo1Metrics, label: 'Servo 1'),
          const SizedBox(height: AppSpacing.sm),
          _JointMetricsCard(metrics: result.servo2Metrics, label: 'Servo 2'),
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('Smoothness (Sum of Squared Jerk)'),
          const SizedBox(height: 4),
          Text(
            'Lower = smoother. Raw signal quality — no pass/fail threshold defined.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SmoothnessCard(
            label: 'Servo 1',
            original: result.servo1Metrics.smoothnessOriginal,
            generated: result.servo1Metrics.smoothnessGenerated,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SmoothnessCard(
            label: 'Servo 2',
            original: result.servo2Metrics.smoothnessOriginal,
            generated: result.servo2Metrics.smoothnessGenerated,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      );
}

class _JointMetricsCard extends StatelessWidget {
  final DmpJointMetrics metrics;
  final String label;
  const _JointMetricsCard({required this.metrics, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.smallRadius,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: AppSpacing.sm),
          _MetricRow('MAE', '${metrics.mae.toStringAsFixed(4)}°'),
          _MetricRow('RMSE', '${metrics.rmse.toStringAsFixed(4)}°'),
          _MetricRow('Max Error', '${metrics.maxError.toStringAsFixed(4)}°'),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetricRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text(value,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.text, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _SmoothnessCard extends StatelessWidget {
  final String label;
  final double original;
  final double generated;
  const _SmoothnessCard(
      {required this.label, required this.original, required this.generated});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.smallRadius,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: AppSpacing.sm),
          _MetricRow('Original (demo)', original.toStringAsFixed(4)),
          _MetricRow('Generated (DMP)', generated.toStringAsFixed(4)),
        ],
      ),
    );
  }
}

// ─── Validation Panel ─────────────────────────────────────────────────────────
class ValidationPanel extends StatelessWidget {
  final DmpResult result;
  const ValidationPanel({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final checks = DmpValidator.validate(result);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trajectory Validation',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...checks.map((c) => _CheckRow(check: c)),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final ValidationCheck check;
  const _CheckRow({required this.check});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (check.status) {
      ValidationStatus.pass => (Icons.check_circle_rounded, AppColors.successGreen),
      ValidationStatus.review => (Icons.warning_amber_rounded, AppColors.warningOrange),
      ValidationStatus.fail => (Icons.cancel_rounded, AppColors.dangerRed),
    };

    final label = switch (check.status) {
      ValidationStatus.pass => 'PASS',
      ValidationStatus.review => 'REVIEW',
      ValidationStatus.fail => 'FAIL',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(check.label,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          )),
                    ),
                  ],
                ),
                Text(check.detail,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Approve / Reject Buttons ──────────────────────────────────────────────────
class ApproveRejectBar extends ConsumerWidget {
  final VoidCallback? onRejected;
  const ApproveRejectBar({super.key, this.onRejected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dmpPreviewProvider);
    final notifier = ref.read(dmpPreviewProvider.notifier);
    final isApproved = state.result?.isApproved ?? false;
    final streamState = ref.watch(dmpStreamerProvider);
    final streamer = ref.read(dmpStreamerProvider.notifier);
    
    final isStreaming = streamState.status != StreamingStatus.idle && 
                        streamState.status != StreamingStatus.ready &&
                        streamState.status != StreamingStatus.completed &&
                        streamState.status != StreamingStatus.aborted &&
                        streamState.status != StreamingStatus.failed;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                notifier.reject();
                onRejected?.call();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.dangerRed),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Reject',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.dangerRed, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isStreaming
                      ? [AppColors.warningOrange, Colors.deepOrange]
                      : isApproved
                          ? [AppColors.successGreen, const Color(0xFF16A34A)]
                          : [AppColors.primary, const Color(0xFF6B5BD6)],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: (isApproved ? AppColors.successGreen : AppColors.primary)
                        .withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isStreaming 
                      ? streamer.abortStreaming 
                      : () {
                          if (state.result != null) streamer.startStreaming(state.result!);
                          notifier.approve();
                        },
                  borderRadius: BorderRadius.circular(100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isStreaming 
                              ? Icons.stop_circle_rounded
                              : isApproved
                                  ? Icons.check_circle_rounded
                                  : Icons.memory_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isStreaming 
                              ? 'ABORT DRY-RUN'
                              : isApproved ? 'Approved ✓' : 'RUN DRY-RUN',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DryRunStreamingStatus extends ConsumerWidget {
  const DryRunStreamingStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dmpStreamerProvider);
    if (state.status == StreamingStatus.idle) return const SizedBox.shrink();

    final statusText = switch (state.status) {
      StreamingStatus.preparing => 'PREPARING',
      StreamingStatus.sendingBegin => 'SENDING BEGIN',
      StreamingStatus.streaming => 'STREAMING',
      StreamingStatus.sendingEnd => 'SENDING END',
      StreamingStatus.ready => 'EXECUTING',
      StreamingStatus.failed => 'FAILED',
      StreamingStatus.aborted => 'ABORTED',
      StreamingStatus.completed => 'COMPLETE',
      _ => '',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: AppRadius.smallRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DRY RUN', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
              Text('ESP32: $statusText', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem('Streaming', '${state.currentChunk} / ${state.totalChunks} chunks'),
              _StatItem('Samples', '${state.samplesTransmitted} / ${state.totalSamples}'),
              _StatItem('Errors', state.error != null ? 'Yes' : 'None'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.progress,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.status == StreamingStatus.failed || state.status == StreamingStatus.aborted
                    ? AppColors.dangerRed
                    : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10)),
        Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
