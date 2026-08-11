import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../vision/presentation/providers/aruco_vision_provider.dart';
import '../../../vision/domain/services/auto_alignment_service.dart';
import '../../../vision/presentation/providers/calibration_provider.dart';
import '../../../vision/presentation/providers/alignment_provider.dart';

class VisionDiagnosticsCard extends ConsumerWidget {
  const VisionDiagnosticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visionState = ref.watch(arucoVisionProvider);
    final autoAlignState = ref.watch(autoAlignmentServiceProvider);
    final calibrationState = ref.watch(calibrationProvider);
    final alignmentState = ref.watch(alignmentProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vision Diagnostics', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          _buildRow('Camera Status:', visionState.status),
          _buildRow('Camera Calibrated:', calibrationState.isValid ? 'YES' : 'NO'),
          _buildRow('Vision FPS:', '${visionState.fps.toStringAsFixed(1)} FPS'),
          _buildRow('Frame Size:', '${visionState.frameWidth} x ${visionState.frameHeight}'),
          _buildRow('Row Stride:', '${visionState.rowStride} bytes'),
          _buildRow('Detected Marker IDs:', visionState.debugIds),
          _buildRow('Active Marker ID:', visionState.detection != null ? '${visionState.detection!.markerId}' : 'None'),
          if (visionState.detection != null)
            _buildRow('Semantic Label:', visionState.detection!.semanticName),
          const Divider(color: Colors.white24),
          Text('Raw Pose Estimation', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          if (visionState.pose != null) ...[
            _buildRow('Translation (X, Y, Z):', '${visionState.pose!.x.toStringAsFixed(2)}, ${visionState.pose!.y.toStringAsFixed(2)}, ${visionState.pose!.z.toStringAsFixed(2)}'),
            _buildRow('Rotation Yaw:', '${visionState.pose!.yaw.toStringAsFixed(2)}°'),
            _buildRow('Distance Error:', '${alignmentState.distanceErrorM.toStringAsFixed(2)}m'),
            _buildRow('Horizontal Error:', '${alignmentState.horizontalErrorM.toStringAsFixed(2)}m'),
            _buildRow('Alignment Score:', '${(alignmentState.score * 100).toStringAsFixed(1)}%'),
          ] else ...[
            _buildRow('Pose:', 'No active pose'),
          ],
          const Divider(color: Colors.white24),
          Text('Auto Alignment System', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          _buildRow('Align State:', autoAlignState.status.name),
          _buildRow('Stable Frames:', '${autoAlignState.stableFrameCount}'),
          _buildRow('Last Command:', autoAlignState.lastCommand.isEmpty ? 'None' : autoAlignState.lastCommand),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTextStyles.bodySmall.copyWith(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
