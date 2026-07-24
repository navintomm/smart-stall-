import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/connection_history.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../providers/connection_provider.dart';

class ConnectionHistoryList extends ConsumerWidget {
  const ConnectionHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectionProvider);
    final logs = state.history;
    
    return GlassCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: logs.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.black12, height: AppSpacing.md),
        itemBuilder: (context, index) {
          final log = logs[index];
          return _ConnectionHistoryTile(log: log);
        },
      ),
    );
  }
}

class _ConnectionHistoryTile extends StatelessWidget {
  final ConnectionHistory log;
  
  const _ConnectionHistoryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isSuccess = log.status == 'Connected';
    final statusColor = isSuccess ? AppColors.successGreen : (log.status == 'Failed' ? AppColors.dangerRed : Colors.black54);
    
    return Row(
      children: [
        Icon(isSuccess ? Icons.link : Icons.link_off, color: statusColor, size: 24),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${log.robotName} via ${log.type}", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text(log.timestamp, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(log.status, style: AppTextStyles.bodyMedium.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
            Text(log.duration, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
          ],
        ),
      ],
    );
  }
}
