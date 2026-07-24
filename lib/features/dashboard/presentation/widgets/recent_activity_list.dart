import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/info_tile.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InfoTile(title: 'Robot Connected', subtitle: '10:45 AM'),
        SizedBox(height: AppSpacing.xs),
        InfoTile(title: 'Cleaning Completed', subtitle: '10:30 AM'),
        SizedBox(height: AppSpacing.xs),
        InfoTile(title: 'Training Saved', subtitle: '09:15 AM'),
        SizedBox(height: AppSpacing.xs),
        InfoTile(title: 'Maintenance Required', subtitle: 'Yesterday'),
        SizedBox(height: AppSpacing.xs),
        InfoTile(title: 'System Boot', subtitle: 'Yesterday'),
      ],
    );
  }
}
