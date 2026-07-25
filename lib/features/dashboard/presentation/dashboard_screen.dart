import 'package:flutter/material.dart';
import '../../../../core/helpers/responsive_helper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/section_header.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/robot_status_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/system_overview_section.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/emergency_stop_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = ResponsiveHelper.isDesktop(context);
            final isTablet = ResponsiveHelper.isTablet(context);

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: DashboardAppBar()),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const RobotStatusCard(),
                      const SizedBox(height: AppSpacing.lg),
                      
                      if (isDesktop || isTablet)
                        _buildMultiColumnLayout()
                      else
                        _buildSingleColumnLayout(),
                        
                      const SizedBox(height: AppSpacing.xl),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Quick Actions'),
        SizedBox(height: AppSpacing.sm),
        QuickActionsGrid(),
        
        SizedBox(height: AppSpacing.lg),
        SectionHeader(title: 'System Overview'),
        SizedBox(height: AppSpacing.sm),
        SystemOverviewSection(),
        
        SizedBox(height: AppSpacing.lg),
        SectionHeader(title: 'Recent Activity'),
        SizedBox(height: AppSpacing.sm),
        RecentActivityList(),
        
        SizedBox(height: AppSpacing.lg),
        EmergencyStopCard(),
      ],
    );
  }

  Widget _buildMultiColumnLayout() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Quick Actions'),
              SizedBox(height: AppSpacing.sm),
              QuickActionsGrid(),
              SizedBox(height: AppSpacing.lg),
              SectionHeader(title: 'System Overview'),
              SizedBox(height: AppSpacing.sm),
              SystemOverviewSection(),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Recent Activity'),
              SizedBox(height: AppSpacing.sm),
              RecentActivityList(),
              SizedBox(height: AppSpacing.lg),
              EmergencyStopCard(),
            ],
          ),
        ),
      ],
    );
  }
}





