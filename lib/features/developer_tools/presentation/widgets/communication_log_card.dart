import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CommunicationLogCard extends ConsumerWidget {
  const CommunicationLogCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      animateEntrance: true,
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Communication Log', style: AppTextStyles.titleLarge),
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.primary),
                tooltip: 'Export Logs',
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildLogItem('INFO', '10:42:01', 'Init HardwareRobotRepository'),
                _buildLogItem('TX', '10:42:02', '{"type":"handshake"}'),
                _buildLogItem('RX', '10:42:02', '{"type":"response","cmdId":0}'),
                _buildLogItem('TX', '10:42:05', '{"type":"command","cmdId":101,"data":{"speed":50}}'),
                _buildLogItem('RX', '10:42:05', '{"type":"response","cmdId":101,"isSuccess":true}'),
                _buildLogItem('WARN', '10:42:08', 'Packet drop detected, retrying...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String type, String time, String message) {
    Color typeColor = Colors.grey;
    if (type == 'TX') typeColor = AppColors.robotBlue;
    if (type == 'RX') typeColor = AppColors.successGreen;
    if (type == 'WARN') typeColor = AppColors.warningOrange;
    if (type == 'ERROR') typeColor = AppColors.dangerRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('[] ', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.textMuted)),
          Text(' ', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: typeColor, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(message, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
