import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/sensor_data.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class VisionDiagnosticsCard extends ConsumerWidget {
  const VisionDiagnosticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        String camStatus = data.firstWhere((s) => s.id == 'cam_status', orElse: () => const SensorData(id: 'cam_status', name: '', value: 'UNKNOWN')).value;
        int camFps = int.tryParse(data.firstWhere((s) => s.id == 'cam_fps', orElse: () => const SensorData(id: 'cam_fps', name: '', value: '0')).value) ?? 0;
        int markerId = int.tryParse(data.firstWhere((s) => s.id == 'marker_id', orElse: () => const SensorData(id: 'marker_id', name: '', value: '0')).value) ?? 0;
        double markerConf = double.tryParse(data.firstWhere((s) => s.id == 'marker_conf', orElse: () => const SensorData(id: 'marker_conf', name: '', value: '0.0')).value) ?? 0.0;
        String locState = data.firstWhere((s) => s.id == 'loc_state', orElse: () => const SensorData(id: 'loc_state', name: '', value: 'UNKNOWN')).value;
        double poseX = double.tryParse(data.firstWhere((s) => s.id == 'pose_x', orElse: () => const SensorData(id: 'pose_x', name: '', value: '0.0')).value) ?? 0.0;
        double poseY = double.tryParse(data.firstWhere((s) => s.id == 'pose_y', orElse: () => const SensorData(id: 'pose_y', name: '', value: '0.0')).value) ?? 0.0;
        double poseZ = double.tryParse(data.firstWhere((s) => s.id == 'pose_z', orElse: () => const SensorData(id: 'pose_z', name: '', value: '0.0')).value) ?? 0.0;
        double poseRoll = double.tryParse(data.firstWhere((s) => s.id == 'pose_roll', orElse: () => const SensorData(id: 'pose_roll', name: '', value: '0.0')).value) ?? 0.0;
        double posePitch = double.tryParse(data.firstWhere((s) => s.id == 'pose_pitch', orElse: () => const SensorData(id: 'pose_pitch', name: '', value: '0.0')).value) ?? 0.0;
        double poseYaw = double.tryParse(data.firstWhere((s) => s.id == 'pose_yaw', orElse: () => const SensorData(id: 'pose_yaw', name: '', value: '0.0')).value) ?? 0.0;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vision Diagnostics', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              _buildRow('Camera Status:', camStatus),
              _buildRow('Camera FPS:', '$camFps FPS'),
              _buildRow('Localization State:', locState),
              _buildRow('Last Marker ID:', '$markerId'),
              _buildRow('Detection Confidence:', '${(markerConf * 100).toStringAsFixed(1)}%'),
              const Divider(color: Colors.white24),
              Text('Raw Pose Estimation', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              _buildRow('Translation (X,Y,Z):', '${poseX.toStringAsFixed(2)}, ${poseY.toStringAsFixed(2)}, ${poseZ.toStringAsFixed(2)}'),
              _buildRow('Rotation (R,P,Y):', '${poseRoll.toStringAsFixed(2)}, ${posePitch.toStringAsFixed(2)}, ${poseYaw.toStringAsFixed(2)}'),
            ],
          ),
        );
      },
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
