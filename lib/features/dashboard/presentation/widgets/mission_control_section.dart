import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/sensor_data.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/actions/gradient_button.dart';
import '../../../../shared/widgets/foundation/glass_button.dart';

class MissionControlSection extends ConsumerWidget {
  const MissionControlSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);
    final commandRepo = ref.watch(robotRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        
        String missionState = data.firstWhere((s) => s.id == 'mission_state', orElse: () => const SensorData(id: 'mission_state', name: '', value: 'IDLE')).value;
        int targetWaypoint = int.tryParse(data.firstWhere((s) => s.id == 'target_waypoint', orElse: () => const SensorData(id: 'target_waypoint', name: '', value: '-1')).value) ?? -1;
        int progress = int.tryParse(data.firstWhere((s) => s.id == 'navigation_progress', orElse: () => const SensorData(id: 'navigation_progress', name: '', value: '0')).value) ?? 0;
        double distRemaining = double.tryParse(data.firstWhere((s) => s.id == 'distance_remaining', orElse: () => const SensorData(id: 'distance_remaining', name: '', value: '0.0')).value) ?? 0.0;
        int missionTime = int.tryParse(data.firstWhere((s) => s.id == 'mission_time', orElse: () => const SensorData(id: 'mission_time', name: '', value: '0')).value) ?? 0;

        String targetName = _getWaypointName(targetWaypoint);

        bool isActive = missionState != 'IDLE' && missionState != 'COMPLETED' && missionState != 'ERROR';

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mission Control', style: AppTextStyles.titleLarge),
                  _buildStateBadge(missionState),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (isActive) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric('Target Zone', targetName, AppColors.primary),
                    _buildMetric('Distance', '${distRemaining.toStringAsFixed(1)}m', AppColors.text),
                    _buildMetric('Time', '${missionTime}s', AppColors.text),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress / 100.0,
                    color: AppColors.primary,
                    backgroundColor: AppColors.textMuted.withOpacity(0.2),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$progress% Complete', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                ),
              ] else ...[
                Text('No active mission. Select a mission below to begin.', style: AppTextStyles.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (!isActive)
                    GradientButton(
                      text: 'Start Standard Mission',
                      onPressed: () => commandRepo.sendCommand('MISSION_START', {"waypoints": [101, 102, 103, 100]}),
                    ),
                  if (isActive && missionState != 'PAUSED')
                    GlassButton(
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.pause), SizedBox(width: 4), Text('Pause')]),
                      onPressed: () => commandRepo.sendCommand('MISSION_PAUSE', {}),
                    ),
                  if (isActive && missionState == 'PAUSED')
                    GradientButton(
                      text: 'Resume',
                      onPressed: () => commandRepo.sendCommand('MISSION_RESUME', {}),
                    ),
                  if (isActive)
                    GlassButton(
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.stop), SizedBox(width: 4), Text('Cancel')]),
                      onPressed: () => commandRepo.sendCommand('MISSION_CANCEL', {}),
                    ),
                  if (!isActive)
                    GlassButton(
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.home), SizedBox(width: 4), Text('Return to Dock')]),
                      onPressed: () => commandRepo.sendCommand('MISSION_START', {"waypoints": [100]}),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getWaypointName(int id) {
    switch (id) {
      case 100: return 'Docking Station';
      case 101: return 'Zone A';
      case 102: return 'Zone B';
      case 103: return 'Zone C';
      case 104: return 'Maintenance';
      default: return 'Unknown';
    }
  }

  Widget _buildStateBadge(String state) {
    Color color = AppColors.textMuted;
    if (state == 'NAVIGATING' || state == 'ALIGNING' || state == 'CLEANING') color = AppColors.primary;
    if (state == 'COMPLETED') color = AppColors.successGreen;
    if (state == 'ERROR' || state == 'EMERGENCY') color = AppColors.dangerRed;
    if (state == 'PAUSED') color = AppColors.warningOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(state, style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.titleLarge.copyWith(color: color)),
      ],
    );
  }
}
