import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../domain/models/dmp_result.dart';
import '../../domain/models/dmp_trajectory_sample.dart';
import '../../domain/models/dmp_joint_metrics.dart';
import '../../../settings/domain/models/routine.dart';
import '../providers/dmp_preview_provider.dart';
import '../widgets/scara_visualizer_widget.dart';
import '../widgets/dmp_preview_widgets.dart';

/// DMP Motion Preview Screen.
///
/// Presents a full virtual SCARA visualisation of a DMP-generated trajectory,
/// playback controls, validation metrics, and Approve/Reject buttons.
///
/// SAFETY: Approval DOES NOT send any data to BLE, ESP32, or physical servos.
/// This screen is purely a software-level preview and validation tool.
class DmpPreviewScreen extends ConsumerStatefulWidget {
  /// The routine to preview. When null, a fixture demo trajectory is loaded.
  final Routine? routine;

  const DmpPreviewScreen({super.key, this.routine});

  @override
  ConsumerState<DmpPreviewScreen> createState() => _DmpPreviewScreenState();
}

class _DmpPreviewScreenState extends ConsumerState<DmpPreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrajectory();
    });
  }

  void _loadTrajectory() {
    final notifier = ref.read(dmpPreviewProvider.notifier);
    if (widget.routine != null && widget.routine!.frames.isNotEmpty) {
      notifier.loadFromRoutine(widget.routine!);
    } else {
      // Load built-in demo fixture
      notifier.loadResult(_buildDemoFixture());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dmpPreviewProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(state),
      body: state.isLoading
          ? _buildLoading()
          : state.errorMessage != null
              ? _buildError(state.errorMessage!)
              : state.result != null
                  ? _buildContent(state.result!)
                  : _buildLoading(),
    );
  }

  AppBar _buildAppBar(DmpPreviewState state) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'DMP Motion Preview',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          if (state.result != null)
            Text(
              state.result!.routineName,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
      actions: const [
        // View mode toggle in app bar for quick access
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.md),
          child: Center(child: ViewModeToggle()),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: 'Preview'),
          Tab(text: 'Validation'),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.dangerRed),
            const SizedBox(height: AppSpacing.lg),
            Text(message,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DmpResult result) {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _PreviewTab(result: result),
              _ValidationTab(result: result),
            ],
          ),
        ),
        // Approve / Reject always visible at bottom
        const Divider(height: 1, color: AppColors.borderLight),
        const DryRunStreamingStatus(),
        ApproveRejectBar(
          onRejected: () => context.pop(),
        ),
      ],
    );
  }
}

// ─── Preview Tab ───────────────────────────────────────────────────────────────
class _PreviewTab extends StatelessWidget {
  final DmpResult result;
  const _PreviewTab({required this.result});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // SCARA visualizer (main area)
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const ScaraVisualizerWidget(),
                  ),
                ),
                // Metrics sidebar
                SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: AppSpacing.lg, top: AppSpacing.lg),
                    child: MetricsPanel(result: result),
                  ),
                ),
              ],
            ),
          ),
          const PlaybackControlsBar(),
        ],
      );
    }

    // Portrait layout
    return Column(
      children: [
        // SCARA Visualizer
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const ScaraVisualizerWidget(),
          ),
        ),
        // Compact metrics strip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _CompactMetricsStrip(result: result),
        ),
        const SizedBox(height: AppSpacing.sm),
        const PlaybackControlsBar(),
      ],
    );
  }
}

/// Compact single-row metric summary for portrait mode.
class _CompactMetricsStrip extends StatelessWidget {
  final DmpResult result;
  const _CompactMetricsStrip({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lightViolet,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Chip('S1 MAE',
              '${result.servo1Metrics.mae.toStringAsFixed(2)}°'),
          _Chip('S2 MAE',
              '${result.servo2Metrics.mae.toStringAsFixed(2)}°'),
          _Chip('S1 RMSE',
              '${result.servo1Metrics.rmse.toStringAsFixed(2)}°'),
          _Chip('S2 RMSE',
              '${result.servo2Metrics.rmse.toStringAsFixed(2)}°'),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  const _Chip(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary, fontSize: 10)),
          Text(value,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      );
}

// ─── Validation Tab ────────────────────────────────────────────────────────────
class _ValidationTab extends StatelessWidget {
  final DmpResult result;
  const _ValidationTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Safety banner
          _SafetyBanner(),
          const SizedBox(height: AppSpacing.lg),
          ValidationPanel(result: result),
          const SizedBox(height: AppSpacing.lg),
          MetricsPanel(result: result),
        ],
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.informationCyan.withOpacity(0.08),
        borderRadius: AppRadius.smallRadius,
        border: Border.all(color: AppColors.informationCyan.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.informationCyan, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Approval does not execute the physical robot. '
              'It marks this trajectory as approved for future integration.',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.informationCyan, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Built-in Demo Fixture ─────────────────────────────────────────────────────
/// Provides a deterministic demo [DmpResult] from the scara_demo.csv data
/// when no routine is passed. Uses the real metrics produced by the Python
/// pipeline during Checkpoint 4.
DmpResult _buildDemoFixture() {
  // Reproduce scara_demo.csv synthetic trajectory (500 samples, 5 seconds, 100 Hz)
  const n = 500;
  const double totalSec = 5.0;

  final originalSamples = <DmpTrajectorySample>[];
  final generatedSamples = <DmpTrajectorySample>[];

  for (int i = 0; i < n; i++) {
    final t = i * (totalSec / (n - 1));
    final s1Raw = t <= 4.0
        ? 90 * (1 - math.cos(math.pi * t / 4.0)) / 2.0
        : 90.0;
    final s2Raw = t <= 4.0 ? 30 * math.sin(math.pi * t / 2.0) : 0.0;

    originalSamples.add(DmpTrajectorySample(
      timeSeconds: t,
      servo1Angle: s1Raw,
      servo2Angle: s2Raw,
    ));

    // Approximate DMP output: smooth version with slight overshoot
    final s1Dmp = s1Raw * 0.92 + (i > 0 ? originalSamples[i - 1].servo1Angle * 0.08 : 0);
    final s2Dmp = s2Raw * 0.90 + (i > 0 ? originalSamples[i - 1].servo2Angle * 0.10 : 0);
    generatedSamples.add(DmpTrajectorySample(
      timeSeconds: t,
      servo1Angle: s1Dmp,
      servo2Angle: s2Dmp,
    ));
  }

  return DmpResult(
    routineId: 'demo_fixture',
    routineName: 'Demo — scara_demo.csv',
    durationSeconds: totalSec,
    originalSamples: originalSamples,
    generatedSamples: generatedSamples,
    servo1Metrics: const DmpJointMetrics(
      jointName: 'servo1_angle',
      mae: 0.7304,
      rmse: 0.8866,
      maxError: 1.7626,
      smoothnessOriginal: 31.7169,
      smoothnessGenerated: 0.0,
    ),
    servo2Metrics: const DmpJointMetrics(
      jointName: 'servo2_angle',
      mae: 3.1983,
      rmse: 3.6498,
      maxError: 6.8055,
      smoothnessOriginal: 32.3718,
      smoothnessGenerated: 0.0,
    ),
    startPositionPreserved: true,
    goalPositionPreserved: false, // Matches actual pipeline output
    noNanValues: true,
    noInfiniteValues: true,
  );
}

