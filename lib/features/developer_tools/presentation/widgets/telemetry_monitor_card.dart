import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

class TelemetryMonitorCard extends ConsumerWidget {
  const TelemetryMonitorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app we'd listen to telemetryProvider.
    return GlassCard(
      animateEntrance: true,
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Telemetry Stream', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _buildTelemetryRow('Battery', '85%'),
          _buildTelemetryRow('Water Tank', '60%'),
          _buildTelemetryRow('Soap Tank', '90%'),
          _buildTelemetryRow('Motor Temp', '42°C'),
          _buildTelemetryRow('Signal Strength', '-65 dBm'),
          _buildTelemetryRow('CPU Usage', '12%'),
          _buildTelemetryRow('Memory Usage', '24%'),
          _buildTelemetryRow('Uptime', '12h 4m'),
        ],
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
