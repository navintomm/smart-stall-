import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/metric_card.dart';

class SystemOverviewSection extends StatelessWidget {
  const SystemOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: const [
            MetricCard(title: "Today's Sessions", value: '12'),
            MetricCard(title: 'Success Rate', value: '100%'),
            MetricCard(title: 'Water Level', value: 'High'),
            MetricCard(title: 'Soap Level', value: 'Medium'),
            MetricCard(title: 'Brush Health', value: 'Good'),
            MetricCard(title: 'Pending Tasks', value: '0'),
            MetricCard(title: 'Maintenance', value: 'None'),
            MetricCard(title: 'Errors', value: '0'),
          ],
        );
      }
    );
  }
}
