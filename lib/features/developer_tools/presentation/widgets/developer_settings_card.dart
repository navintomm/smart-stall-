import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class DeveloperSettingsCard extends ConsumerStatefulWidget {
  const DeveloperSettingsCard({super.key});

  @override
  ConsumerState<DeveloperSettingsCard> createState() => _DeveloperSettingsCardState();
}

class _DeveloperSettingsCardState extends ConsumerState<DeveloperSettingsCard> {
  bool _simMode = true;
  bool _verboseLog = false;
  bool _protoDebug = true;
  double _mockQuality = 100;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      animateEntrance: true,
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Developer Settings', style: AppTextStyles.titleLarge),
          SwitchListTile(
            title: Text('Simulation Mode', style: AppTextStyles.bodyLarge),
            subtitle: Text('Use mock hardware responses', style: AppTextStyles.bodySmall),
            value: _simMode,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _simMode = val),
          ),
          SwitchListTile(
            title: Text('Verbose Logging', style: AppTextStyles.bodyLarge),
            value: _verboseLog,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _verboseLog = val),
          ),
          SwitchListTile(
            title: Text('Protocol Debugging', style: AppTextStyles.bodyLarge),
            value: _protoDebug,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _protoDebug = val),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mock Network Quality (${_mockQuality.toInt()}%):', style: AppTextStyles.bodyMedium),
                Slider(
                  value: _mockQuality,
                  min: 0,
                  max: 100,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _mockQuality = val),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
