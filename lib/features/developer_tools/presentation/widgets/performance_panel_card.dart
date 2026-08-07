import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../shared/models/sensor_data.dart';

class PerformancePanelCard extends ConsumerWidget {
  const PerformancePanelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        
        final fps = data.firstWhere((s) => s.id == 'sys_fps', orElse: () => const SensorData(id: 'sys_fps', name: '', value: '0')).value;
        final loop = data.firstWhere((s) => s.id == 'sys_loop_ms', orElse: () => const SensorData(id: 'sys_loop_ms', name: '', value: '0')).value;
        final heapRaw = int.tryParse(data.firstWhere((s) => s.id == 'sys_heap', orElse: () => const SensorData(id: 'sys_heap', name: '', value: '0')).value) ?? 0;
        final wdgRaw = data.firstWhere((s) => s.id == 'sys_wdg', orElse: () => const SensorData(id: 'sys_wdg', name: '', value: 'false')).value;

        final heap = (heapRaw / 1024).toStringAsFixed(1);
        final wdg = wdgRaw == 'true' ? 'FAIL' : 'OK';

        return GlassCard(
          animateEntrance: true,
          delay: const Duration(milliseconds: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Firmware System Health', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric('Loop (ms)', loop),
                  _buildMetric('FPS', fps),
                  _buildMetric('Free Heap (KB)', heap),
                  _buildMetric('Watchdog', wdg, isWarning: wdg == 'FAIL'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetric(String label, String value, {bool isWarning = false}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displayMedium.copyWith(
            color: isWarning ? Colors.redAccent : null,
          ),
        ),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
