import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../shared/models/sensor_data.dart';

class TelemetryMonitorCard extends ConsumerWidget {
  const TelemetryMonitorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);

    return GlassCard(
      animateEntrance: true,
      delay: const Duration(milliseconds: 300),
      child: StreamBuilder<List<SensorData>>(
        stream: telemetryRepo.sensorDataStream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? [];
          
          String getVal(String id, String fallback) {
            return data.firstWhere((s) => s.id == id, orElse: () => SensorData(id: id, name: '', value: fallback)).value;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Telemetry Stream', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              _buildTelemetryRow('Water Tank', getVal('water', 'Unknown')),
              _buildTelemetryRow('Soap Tank', getVal('soap', 'Unknown')),
              _buildTelemetryRow('Motor Temp', getVal('temp', 'Unknown')),
              _buildTelemetryRow('Obstacle Dist', getVal('obs', 'Unknown')),
              _buildTelemetryRow('Signal Strength', getVal('rssi', 'Unknown')),
              _buildTelemetryRow('Emergency State', getVal('emg', 'INACTIVE')),
            ],
          );
        }
      ),
    );
  }

  Widget _buildTelemetryRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: AppTextStyles.bodyMedium),
          Text(val, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
