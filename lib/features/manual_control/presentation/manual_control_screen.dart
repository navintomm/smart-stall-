import 'package:flutter/material.dart';
import '../../../../core/helpers/responsive_helper.dart';
import '../../../../shared/widgets/navigation/navigation_header.dart';
import '../../../../core/theme/app_icons.dart';
import 'layouts/manual_control_mobile_layout.dart';
import 'layouts/manual_control_tablet_layout.dart';
import 'layouts/manual_control_desktop_layout.dart';

class ManualControlScreen extends StatelessWidget {
  const ManualControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const NavigationHeader(title: 'Manual Control', icon: AppIcons.robot),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (ResponsiveHelper.isDesktop(context)) {
                    return const ManualControlDesktopLayout();
                  } else if (ResponsiveHelper.isTablet(context)) {
                    return const ManualControlTabletLayout();
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

