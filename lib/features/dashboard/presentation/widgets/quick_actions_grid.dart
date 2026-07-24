import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/navigation/module_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 400 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            ModuleCard(
              title: 'Auto Cleaning',
              description: 'Standard sequence',
              icon: AppIcons.water,
              onTap: () => context.push(AppRoutes.autoCleaning),
            ),
            ModuleCard(
              title: 'Manual Control',
              description: 'Direct operation',
              icon: AppIcons.robot,
              onTap: () => context.push(AppRoutes.manualControl),
            ),
            ModuleCard(
              title: 'Training Studio',
              description: 'Record paths',
              icon: AppIcons.training,
              onTap: () => context.push(AppRoutes.training),
            ),
            ModuleCard(
              title: 'ArUco Scanner',
              description: 'Calibrate markers',
              icon: AppIcons.camera,
              onTap: () => context.push(AppRoutes.arucoScanner),
            ),
            ModuleCard(
              title: 'Connection',
              description: 'Bluetooth link',
              icon: AppIcons.bluetooth,
              onTap: () => context.push(AppRoutes.connection),
            ),
            ModuleCard(
              title: 'Diagnostics',
              description: 'System health',
              icon: AppIcons.maintenance,
              onTap: () => context.push(AppRoutes.maintenance),
            ),
            ModuleCard(
              title: 'Reports',
              description: 'Past logs',
              icon: AppIcons.history,
              onTap: () => context.push(AppRoutes.history),
            ),
            ModuleCard(
              title: 'Settings',
              description: 'Preferences',
              icon: AppIcons.settings,
              onTap: () => context.push(AppRoutes.settings),
            ),
          ],
        );
      }
    );
  }
}
