import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/section_header.dart';
import '../widgets/connection_overview_card.dart';
import '../widgets/robot_card.dart';
import '../widgets/connection_method_card.dart';
import '../widgets/network_metric_card.dart';
import '../widgets/connection_history_list.dart';
import '../widgets/system_info_card.dart';
import '../providers/connection_provider.dart';

class ConnectionDesktopLayout extends ConsumerWidget {
  const ConnectionDesktopLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectionProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Active Connection'),
                const SizedBox(height: AppSpacing.sm),
                const ConnectionOverviewCard(),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Connection Methods'),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 3,
                  children: state.methods.map((m) => ConnectionMethodCard(method: m)).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Available Robots'),
                const SizedBox(height: AppSpacing.sm),
                ...state.availableRobots.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: RobotCard(robot: r),
                )),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Network Diagnostics'),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.5,
                  children: state.metrics.map((m) => NetworkMetricCard(metric: m)).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          const Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'Connection History'),
                SizedBox(height: AppSpacing.sm),
                ConnectionHistoryList(),
                SizedBox(height: AppSpacing.lg),
                SectionHeader(title: 'System Information'),
                SizedBox(height: AppSpacing.sm),
                SystemInfoCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
