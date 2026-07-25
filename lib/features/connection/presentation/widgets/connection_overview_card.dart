import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/status_chip.dart';
import 'signal_strength_indicator.dart';

class ConnectionOverviewCard extends StatelessWidget {
  const ConnectionOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      animateEntrance: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.robot, size: 40, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AlphaBot-01', style: AppTextStyles.displayMedium),
                        Text('ID: r001 • Wi-Fi', style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const StatusChip(label: 'ACTIVE', color: AppColors.successGreen),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(label: 'Uptime', value: '4h 12m'),
                _StatItem(label: 'Battery', value: '87%'),
                _StatItem(label: 'IP Address', value: '192.168.1.105'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Signal', style: TextStyle(color: Colors.black54, fontSize: 14)),
                    SizedBox(height: 8),
                    SignalStrengthIndicator(quality: 95),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}


