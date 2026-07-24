import 'package:flutter/material.dart';
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';

class AutoCleaningScreen extends StatelessWidget {
  const AutoCleaningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavigationHeader(
              title: 'Automatic Cleaning',
              icon: AppIcons.water,
            ),
            Expanded(
              child: Center(
                child: Text('Placeholder for Automatic Cleaning Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


