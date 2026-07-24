import 'package:flutter/material.dart';
import '../../domain/models/command_log_entry.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class CommandLogList extends StatelessWidget {
  const CommandLogList({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = CommandLogEntry.placeholders;
    return GlassCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: logs.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.black12, height: AppSpacing.md),
        itemBuilder: (context, index) {
          final log = logs[index];
          return _CommandLogTile(log: log);
        },
      ),
    );
  }
}

class _CommandLogTile extends StatelessWidget {
  final CommandLogEntry log;
  
  const _CommandLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(log.icon, color: log.statusColor, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log.command, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text("${log.timestamp} • ${log.source}", style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
            ],
          ),
        ),
        Text(log.status, style: AppTextStyles.bodyMedium.copyWith(color: log.statusColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
