import 'package:flutter/material.dart';
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';

class ArucoScannerScreen extends StatelessWidget {
  const ArucoScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavigationHeader(
              title: 'ArUco Scanner',
              icon: AppIcons.camera,
            ),
            Expanded(
              child: Center(
                child: Text('Placeholder for ArUco Scanner Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


