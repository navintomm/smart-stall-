import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AiDiagnosticsCard extends ConsumerWidget {
  const AiDiagnosticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real implementation, we would watch a provider that exposes the latest AI stats.
    // For Phase 21, we display placeholder or basic values as requested.
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('AI Diagnostics', style: AppTextStyles.titleLarge),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.5)),
                  ),
                  child: Text(
                    'SIMULATION / DEV',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.successGreen),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            
            _buildStatRow('Model Status', 'Ready (Mock)'),
            _buildStatRow('Model Version', 'MOCK-v0.1-DEV'),
            _buildStatRow('Inference Time', '~85 ms'),
            _buildStatRow('Inference FPS', '11 FPS'),
            const Divider(height: AppSpacing.xl),
            _buildStatRow('Last Confidence', '--'),
            _buildStatRow('Last Severity', '--'),
            _buildStatRow('Affected Area', '--'),
            _buildStatRow('Recommended Profile', '--'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
