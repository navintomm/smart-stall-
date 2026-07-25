import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/metric_card.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../shared/models/sensor_data.dart';

class SystemOverviewSection extends ConsumerWidget {
  const SystemOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);
    
    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        
        String water = data.firstWhere((s) => s.id == 'water', orElse: () => const SensorData(id: 'water', name: '', value: 'Unknown')).value;
        String soap = data.firstWhere((s) => s.id == 'soap', orElse: () => const SensorData(id: 'soap', name: '', value: 'Unknown')).value;
        String temp = data.firstWhere((s) => s.id == 'temp', orElse: () => const SensorData(id: 'temp', name: '', value: 'Unknown')).value;
        String obs = data.firstWhere((s) => s.id == 'obs', orElse: () => const SensorData(id: 'obs', name: '', value: 'Unknown')).value;

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                const MetricCard(title: "Today's Sessions", value: '12'),
                const MetricCard(title: 'Success Rate', value: '100%'),
                MetricCard(title: 'Water Level', value: water),
                MetricCard(title: 'Soap Level', value: soap),
                MetricCard(title: 'Motor Temp', value: temp),
                MetricCard(title: 'Obstacle Dist', value: obs),
                const MetricCard(title: 'Maintenance', value: 'None'),
                const MetricCard(title: 'Errors', value: '0'),
              ],
            );
          }
        );
      }
    );
  }
}
