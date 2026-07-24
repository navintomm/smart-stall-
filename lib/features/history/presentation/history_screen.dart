import 'package:flutter/material.dart';
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavigationHeader(
              title: 'History',
              icon: AppIcons.history,
            ),
            Expanded(
              child: Center(
                child: Text('Placeholder for History Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


