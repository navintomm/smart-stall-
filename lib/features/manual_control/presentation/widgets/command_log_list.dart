import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/command_log_entry.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../providers/manual_control_provider.dart';

class CommandLogList extends ConsumerWidget {
  const CommandLogList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manualControlProvider);
    final logs = state.logs;
    
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
        Icon(log.icon, color: Colors.black54, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log.command, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text("${log.source} • ${log.status}", style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
            ],
          ),
        ),
        Text(log.timestamp, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
      ],
    );
  }
}
