import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/sensor_data.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class CleaningDiagnosticsCard extends ConsumerWidget {
  const CleaningDiagnosticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        String cleanState = data.firstWhere((s) => s.id == 'clean_state', orElse: () => const SensorData(id: 'clean_state', name: '', value: 'IDLE')).value;
        int cleanProgress = int.tryParse(data.firstWhere((s) => s.id == 'clean_progress', orElse: () => const SensorData(id: 'clean_progress', name: '', value: '0')).value) ?? 0;
        int cleanElapsed = int.tryParse(data.firstWhere((s) => s.id == 'clean_elapsed', orElse: () => const SensorData(id: 'clean_elapsed', name: '', value: '0')).value) ?? 0;
        int cleanRemaining = int.tryParse(data.firstWhere((s) => s.id == 'clean_remaining', orElse: () => const SensorData(id: 'clean_remaining', name: '', value: '0')).value) ?? 0;
        String abortReason = data.firstWhere((s) => s.id == 'abort_reason', orElse: () => const SensorData(id: 'abort_reason', name: '', value: 'None')).value;
        int cleanCycle = int.tryParse(data.firstWhere((s) => s.id == 'clean_cycle', orElse: () => const SensorData(id: 'clean_cycle', name: '', value: '0')).value) ?? 0;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cleaning Diagnostics', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              _buildRow('Current State:', cleanState),
              _buildRow('Progress:', '$cleanProgress%'),
              _buildRow('Elapsed Time:', '${cleanElapsed}s'),
              _buildRow('Est. Remaining:', '${cleanRemaining}s'),
              _buildRow('Last Abort Reason:', abortReason.isEmpty ? 'None' : abortReason),
              _buildRow('Cleaning Cycle Count:', '$cleanCycle'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
