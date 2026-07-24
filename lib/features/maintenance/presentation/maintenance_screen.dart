import 'package:flutter/material.dart';
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavigationHeader(
              title: 'Maintenance',
              icon: AppIcons.maintenance,
            ),
            Expanded(
              child: Center(
                child: Text('Placeholder for Maintenance Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


