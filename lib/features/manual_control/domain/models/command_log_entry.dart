import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CommandLogEntry {
  final String timestamp;
  final String command;
  final String source;
  final String status;
  final IconData icon;
  final Color statusColor;

  const CommandLogEntry({
    required this.timestamp,
    required this.command,
    required this.source,
    required this.status,
    required this.icon,
    required this.statusColor,
  });

  static List<CommandLogEntry> get placeholders => [
    const CommandLogEntry(timestamp: '14:02:11', command: 'Move Forward', source: 'Operator', status: 'Success', icon: Icons.arrow_upward, statusColor: AppColors.successGreen),
    const CommandLogEntry(timestamp: '14:01:45', command: 'Rotate Arm', source: 'Operator', status: 'Success', icon: Icons.rotate_right, statusColor: AppColors.successGreen),
    const CommandLogEntry(timestamp: '14:00:12', command: 'Pump Activated', source: 'System', status: 'Warning', icon: Icons.warning, statusColor: AppColors.warningOrange),
    const CommandLogEntry(timestamp: '13:59:05', command: 'Brush Enabled', source: 'Operator', status: 'Success', icon: Icons.settings, statusColor: AppColors.successGreen),
    const CommandLogEntry(timestamp: '13:58:10', command: 'Emergency Reset', source: 'Operator', status: 'Failed', icon: Icons.error, statusColor: AppColors.dangerRed),
  ];
}
