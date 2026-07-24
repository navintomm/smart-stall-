import 'package:flutter/material.dart';
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavigationHeader(
              title: 'Connection Manager',
              icon: AppIcons.bluetooth,
            ),
            Expanded(
              child: Center(
                child: Text('Placeholder for Connection Manager Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


