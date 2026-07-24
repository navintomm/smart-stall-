import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/info_tile.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class SystemHealthPanel extends StatelessWidget {
  const SystemHealthPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            InfoTile(title: 'ESP32 Connection', subtitle: 'Stable'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'Wi-Fi Status', subtitle: 'Connected (SSID: SmartStall_Net)'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'Bluetooth', subtitle: 'Paired'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'AI Status', subtitle: 'Model Loaded v1.2'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'Firmware', subtitle: 'v2.0.4'),
            SizedBox(height: AppSpacing.sm),
            InfoTile(title: 'Latency', subtitle: '12ms'),
          ],
        ),
      ),
    );
  }
}
