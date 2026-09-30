import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/dmp_result.dart';
import '../../domain/services/scara_kinematics.dart';
import '../providers/dmp_preview_provider.dart';
import 'scara_painter.dart';

/// Animated SCARA visualisation widget with trail accumulation.
///
/// Listens to [DmpPreviewState.playbackProgress] and rebuilds the arm pose
/// on every tick via a Ticker managed by a parent AnimationController.
class ScaraVisualizerWidget extends ConsumerStatefulWidget {
  const ScaraVisualizerWidget({super.key});

  @override
  ConsumerState<ScaraVisualizerWidget> createState() => _ScaraVisualizerWidgetState();
}

class _ScaraVisualizerWidgetState extends ConsumerState<ScaraVisualizerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Offset> _originalTrail = [];
  final List<Offset> _dmpTrail = [];
  static const int _maxTrailLength = 300;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);
  }

  void _onTick() {
    final previewState = ref.read(dmpPreviewProvider);
    final result = previewState.result;
    if (result == null) return;

    final progress = _controller.value;
    ref.read(dmpPreviewProvider.notifier).updateProgress(progress);

    // Accumulate trail
    _accumulateTrail(result, progress);
  }

  // Trail computation happens in build() via LayoutBuilder for accurate canvas coords.
  void _accumulateTrail(DmpResult result, double progress) {}

  @override
  void didUpdateWidget(ScaraVisualizerWidget old) {
    super.didUpdateWidget(old);
    final previewState = ref.read(dmpPreviewProvider);
    if (previewState.playbackStatus == PlaybackStatus.playing) {
      final speed = previewState.playbackSpeed;
      final result = previewState.result;
      if (result != null) {
        _controller.duration = Duration(
          milliseconds: (result.durationSeconds * 1000 / speed).round(),
        );
        if (!_controller.isAnimating) {
          _controller.forward(from: previewState.playbackProgress);
        }
      }
    } else if (previewState.playbackStatus == PlaybackStatus.paused ||
               previewState.playbackStatus == PlaybackStatus.idle) {
      if (_controller.isAnimating) _controller.stop();
      if (previewState.playbackProgress == 0.0) {
        _controller.reset();
        _originalTrail.clear();
        _dmpTrail.clear();
      }
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      ref.read(dmpPreviewProvider.notifier).onPlaybackComplete();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewState = ref.watch(dmpPreviewProvider);
    final result = previewState.result;

    // Drive animation when state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final st = ref.read(dmpPreviewProvider);
      if (st.playbackStatus == PlaybackStatus.playing) {
        final speed = st.playbackSpeed;
        final r = st.result;
        if (r != null) {
          _controller.duration = Duration(
            milliseconds: (r.durationSeconds * 1000 / speed).round().clamp(100, 999999),
          );
          if (!_controller.isAnimating) {
            _controller.forward(from: st.playbackProgress);
          }
        }
      } else if (st.playbackStatus == PlaybackStatus.idle &&
                 st.playbackProgress == 0.0) {
        _controller.reset();
        _originalTrail.clear();
        _dmpTrail.clear();
      } else if (st.playbackStatus == PlaybackStatus.paused) {
        if (_controller.isAnimating) _controller.stop();
      }
    });

    if (result == null) {
      return _buildEmptyState();
    }

    final n = result.generatedSamples.length;
    if (n == 0) return _buildEmptyState();

    final progress = previewState.playbackProgress;
    final idx = (progress * (n - 1)).round().clamp(0, n - 1);
    final dmpSample = result.generatedSamples[idx];
    final origIdx = result.originalSamples.length > idx ? idx : result.originalSamples.length - 1;
    final origSample = result.originalSamples.isNotEmpty
        ? result.originalSamples[origIdx]
        : dmpSample;
    final viewMode = previewState.viewMode;

    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final origin = Offset(size.width / 2, size.height / 2);

      // Compute trail up to current index
      final dmpTrailPoints = <Offset>[];
      final origTrailPoints = <Offset>[];
      if (previewState.showTrail) {
        final stride = (n / _maxTrailLength).ceil().clamp(1, n);
        for (int i = 0; i <= idx; i += stride) {
          final pos = ScaraKinematics.solve(
            servo1Deg: result.generatedSamples[i].servo1Angle,
            servo2Deg: result.generatedSamples[i].servo2Angle,
            origin: origin,
          );
          dmpTrailPoints.add(pos.endEffector);

          if (viewMode == TrajectoryViewMode.compare &&
              result.originalSamples.length > i) {
            final opos = ScaraKinematics.solve(
              servo1Deg: result.originalSamples[i].servo1Angle,
              servo2Deg: result.originalSamples[i].servo2Angle,
              origin: origin,
            );
            origTrailPoints.add(opos.endEffector);
          }
        }
      }

      if (viewMode == TrajectoryViewMode.compare) {
        return CustomPaint(
          size: size,
          painter: ScaraComparePainter(
            originalSample: origSample,
            dmpSample: dmpSample,
            originalTrail: origTrailPoints,
            dmpTrail: dmpTrailPoints,
            showTrail: previewState.showTrail,
          ),
        );
      }

      final activeSample = viewMode == TrajectoryViewMode.original ? origSample : dmpSample;
      final armColor = viewMode == TrajectoryViewMode.original
          ? ScaraComparePainter.originalColor
          : ScaraComparePainter.dmpColor;

      return CustomPaint(
        size: size,
        painter: ScaraPainter(
          currentSample: activeSample,
          trailPoints: dmpTrailPoints,
          showTrail: previewState.showTrail,
          armColor: armColor,
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.smart_toy_outlined,
              size: 56, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          Text('No trajectory loaded',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              )),
        ],
      ),
    );
  }
}
