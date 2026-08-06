import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/sensor_data.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class VisionLocalizationCard extends ConsumerWidget {
  const VisionLocalizationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        String locState = data.firstWhere((s) => s.id == 'loc_state', orElse: () => const SensorData(id: 'loc_state', name: '', value: 'UNKNOWN')).value;
        String camStatus = data.firstWhere((s) => s.id == 'cam_status', orElse: () => const SensorData(id: 'cam_status', name: '', value: 'UNKNOWN')).value;
        int markerId = int.tryParse(data.firstWhere((s) => s.id == 'marker_id', orElse: () => const SensorData(id: 'marker_id', name: '', value: '0')).value) ?? 0;
        int alignScore = int.tryParse(data.firstWhere((s) => s.id == 'align_score', orElse: () => const SensorData(id: 'align_score', name: '', value: '0')).value) ?? 0;
        double markerDist = double.tryParse(data.firstWhere((s) => s.id == 'marker_dist', orElse: () => const SensorData(id: 'marker_dist', name: '', value: '0.0')).value) ?? 0.0;
        
        String markerName = markerId == 1 ? 'Western Toilet' : markerId == 2 ? 'Indian Toilet' : markerId == 3 ? 'Urinal' : 'Unknown';

        Color statusColor = locState == 'READY' ? AppColors.successGreen : (locState == 'LOST' || locState == 'ERROR' ? AppColors.dangerRed : AppColors.warningOrange);

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vision & Localization', style: AppTextStyles.titleLarge),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(locState, style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetric('Camera', camStatus, camStatus == 'OK' ? AppColors.successGreen : AppColors.dangerRed),
                  _buildMetric('Alignment', '$alignScore%', alignScore >= 95 ? AppColors.successGreen : AppColors.warningOrange),
                  _buildMetric('Distance', '${markerDist.toStringAsFixed(2)}m', AppColors.primary),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Detected Marker:', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                  Text(markerId > 0 ? '$markerName (ID $markerId)' : 'None', style: AppTextStyles.bodyMedium),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleLarge.copyWith(color: color)),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}
