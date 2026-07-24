import 'package:flutter/material.dart';
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavigationHeader(
              title: 'Training Studio',
              icon: AppIcons.training,
            ),
            Expanded(
              child: Center(
                child: Text('Placeholder for Training Studio Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


