import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/sensor_data.dart';

class SafetyAlertBanner extends ConsumerWidget {
  const SafetyAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        
        final data = snapshot.data!;
        
        // Safety rules
        bool isWaterLow = false;
        bool isSoapLow = false;
        bool isOverheat = false;
        bool isEmergency = false;

        for (var sensor in data) {
          if (sensor.id == 'water') {
            final val = double.tryParse(sensor.value.replaceAll('%', '').trim()) ?? 100;
            if (val <= 10) isWaterLow = true;
          }
          if (sensor.id == 'soap') {
            final val = double.tryParse(sensor.value.replaceAll('%', '').trim()) ?? 100;
            if (val <= 10) isSoapLow = true;
          }
          if (sensor.id == 'temp') {
            final val = double.tryParse(sensor.value.replaceAll('C', '').trim()) ?? 25;
            if (val >= 80) isOverheat = true;
          }
          if (sensor.id == 'emg' && sensor.value == 'ACTIVE') {
            isEmergency = true;
          }
        }

        List<Widget> alerts = [];

        if (isEmergency) {
          alerts.add(_buildAlertChip(context, 'EMERGENCY STOP ACTIVE', AppColors.dangerRed));
        } else if (isOverheat) {
          alerts.add(_buildAlertChip(context, 'CRITICAL TEMP', AppColors.dangerRed));
        } else {
          if (isWaterLow) alerts.add(_buildAlertChip(context, 'Low Water', AppColors.warningOrange));
          if (isSoapLow) alerts.add(_buildAlertChip(context, 'Low Soap', AppColors.warningOrange));
        }

        if (alerts.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: alerts,
          ),
        );
      },
    );
  }

  Widget _buildAlertChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
