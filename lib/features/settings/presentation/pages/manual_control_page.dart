import 'package:flutter/material.dart';
import '../../../../core/helpers/responsive_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/widgets/navigation/navigation_header.dart';
import '../../../../features/manual_control/presentation/layouts/manual_control_mobile_layout.dart';
import '../../../../features/manual_control/presentation/layouts/manual_control_tablet_layout.dart';
import '../../../../features/manual_control/presentation/layouts/manual_control_desktop_layout.dart';
import '../../../../features/manual_control/presentation/layouts/manual_control_landscape_layout.dart';

/// Thin wrapper that re-hosts the existing ManualControl layouts inside Settings.
/// Adds a "Maintenance & Testing Mode" warning banner at the top.
class ManualControlPage extends StatelessWidget {
  const ManualControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const NavigationHeader(
              title: 'Manual Control',
              icon: AppIcons.robot,
            ),

            // Maintenance banner
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withOpacity(0.08),
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(
                      color: AppColors.dangerRed.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.warning,
                        color: AppColors.dangerRed, size: 18),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Maintenance & Testing Mode — for authorised technicians only.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.dangerRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Existing layout (unchanged)
            Expanded(
              child: LayoutBuilder(
                builder: (context, _) {
                  if (ResponsiveHelper.isDesktop(context)) {
                    return const ManualControlDesktopLayout();
                  } else if (ResponsiveHelper.isTablet(context)) {
                    return const ManualControlTabletLayout();
                  } else if (ResponsiveHelper.isLandscape(context)) {
                    return const ManualControlLandscapeLayout();
                  } else {
                    return const ManualControlMobileLayout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
