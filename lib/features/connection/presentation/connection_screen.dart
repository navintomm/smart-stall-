import 'package:flutter/material.dart';
import '../../../../core/helpers/responsive_helper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/navigation/navigation_header.dart';
import 'layouts/connection_mobile_layout.dart';
import 'layouts/connection_tablet_layout.dart';
import 'layouts/connection_desktop_layout.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const NavigationHeader(title: 'Robot Connection', icon: AppIcons.bluetooth),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (ResponsiveHelper.isDesktop(context)) {
                    return const ConnectionDesktopLayout();
                  } else if (ResponsiveHelper.isTablet(context)) {
                    return const ConnectionTabletLayout();
                  } else {
                    return const ConnectionMobileLayout();
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
