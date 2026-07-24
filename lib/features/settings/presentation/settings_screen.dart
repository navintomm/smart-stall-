import 'package:flutter/material.dart';
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavigationHeader(
              title: 'Settings',
              icon: AppIcons.settings,
            ),
            Expanded(
              child: Center(
                child: Text('Placeholder for Settings Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


