import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/sensor_data.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class AutonomousCleaningSection extends ConsumerWidget {
  const AutonomousCleaningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);
    final robotController = ref.watch(robotRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        
        String cleanState = data.firstWhere((s) => s.id == 'clean_state', orElse: () => const SensorData(id: 'clean_state', name: '', value: 'IDLE')).value;
        String cleanStep = data.firstWhere((s) => s.id == 'clean_step', orElse: () => const SensorData(id: 'clean_step', name: '', value: 'Idle')).value;
        int cleanProg = int.tryParse(data.firstWhere((s) => s.id == 'clean_prog', orElse: () => const SensorData(id: 'clean_prog', name: '', value: '0')).value) ?? 0;
        int cleanRem = int.tryParse(data.firstWhere((s) => s.id == 'clean_rem', orElse: () => const SensorData(id: 'clean_rem', name: '', value: '0')).value) ?? 0;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Autonomous Cleaning', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('State: $cleanState', style: AppTextStyles.bodyMedium),
                  Text('Step: $cleanStep', style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: cleanProg / 100.0,
                backgroundColor: AppColors.textMuted.withOpacity(0.2),
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$cleanProg%', style: AppTextStyles.bodySmall),
                  Text('${cleanRem}s remaining', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => robotController.sendCommand('START_CLEANING', {}),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => robotController.sendCommand('PAUSE_CLEANING', {}),
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.warningOrange, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => robotController.sendCommand('RESUME_CLEANING', {}),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.robotBlue, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => robotController.sendCommand('STOP_CLEANING', {}),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
