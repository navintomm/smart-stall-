import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/sensor_data.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class NavigationDiagnosticsCard extends ConsumerWidget {
  const NavigationDiagnosticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        String missionState = data.firstWhere((s) => s.id == 'mission_state', orElse: () => const SensorData(id: 'mission_state', name: '', value: 'IDLE')).value;
        String navState = data.firstWhere((s) => s.id == 'nav_state', orElse: () => const SensorData(id: 'nav_state', name: '', value: 'IDLE')).value;
        int currentWaypoint = int.tryParse(data.firstWhere((s) => s.id == 'current_waypoint', orElse: () => const SensorData(id: 'current_waypoint', name: '', value: '-1')).value) ?? -1;
        int targetWaypoint = int.tryParse(data.firstWhere((s) => s.id == 'target_waypoint', orElse: () => const SensorData(id: 'target_waypoint', name: '', value: '-1')).value) ?? -1;
        double distRemaining = double.tryParse(data.firstWhere((s) => s.id == 'distance_remaining', orElse: () => const SensorData(id: 'distance_remaining', name: '', value: '0.0')).value) ?? 0.0;
        int alignScore = int.tryParse(data.firstWhere((s) => s.id == 'align_score', orElse: () => const SensorData(id: 'align_score', name: '', value: '0')).value) ?? 0;
        
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Navigation Diagnostics', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              _buildRow('Mission State:', missionState),
              _buildRow('Navigation State:', navState),
              _buildRow('Current WP ID:', '$currentWaypoint'),
              _buildRow('Target WP ID:', '$targetWaypoint'),
              _buildRow('Dist. Remaining:', '${distRemaining.toStringAsFixed(3)} m'),
              _buildRow('Alignment Score:', '$alignScore%'),
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
