import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/display/info_tile.dart';

class SystemInfoCard extends StatelessWidget {
  const SystemInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            InfoTile(title: 'App Version', subtitle: '1.0.0 (Build 42)'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'Protocol Version', subtitle: 'v3.1 - Binary'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'SDK Version', subtitle: 'Dart 3.4.0'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'ESP32 Firmware', subtitle: '2.4.1-stable'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'Hardware Revision', subtitle: 'Rev-B'),
          ],
        ),
      ),
    );
  }
}
