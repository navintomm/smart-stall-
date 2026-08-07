import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ConnectionAlertBanner extends ConsumerWidget {
  const ConnectionAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionRepo = ref.watch(connectionRepositoryProvider);

    return StreamBuilder<String>(
      stream: connectionRepo.connectionStateStream,
      initialData: 'DISCONNECTED',
      builder: (context, snapshot) {
        final state = snapshot.data ?? 'DISCONNECTED';
        
        if (state == 'CONNECTED') {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.dangerRed.withOpacity(0.15),
              border: Border.all(color: AppColors.dangerRed.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: AppColors.dangerRed, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CONNECTION LOST', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
                      Text('Attempting to reconnect to SmartStall robot...', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.dangerRed),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
