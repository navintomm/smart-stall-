import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';


import '../../core/theme/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../shared/widgets/foundation/animated_glass_container.dart';
import '../../shared/widgets/foundation/glass_card.dart';
import '../../shared/widgets/foundation/glass_button.dart';
import '../../shared/widgets/foundation/glass_icon_button.dart';
import '../../shared/widgets/actions/gradient_button.dart';
import '../../shared/widgets/actions/primary_action_card.dart';
import '../../shared/widgets/display/metric_card.dart';
import '../../shared/widgets/display/info_tile.dart';
import '../../shared/widgets/display/section_header.dart';
import '../../shared/widgets/display/circular_progress_glass.dart';
import '../../shared/widgets/feedback/status_chip.dart';
import '../../shared/widgets/feedback/status_indicator.dart';
import '../../shared/widgets/feedback/empty_state_widget.dart';
import '../../shared/widgets/feedback/loading_overlay.dart';
import '../../shared/widgets/navigation/custom_app_bar.dart';

class UiShowcaseScreen extends StatefulWidget {
  const UiShowcaseScreen({super.key});

  @override
  State<UiShowcaseScreen> createState() => _UiShowcaseScreenState();
}

class _UiShowcaseScreenState extends State<UiShowcaseScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'UI Showcase'),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SectionHeader(title: '1. Theme Tokens'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _colorBox(AppColors.primary, 'Primary'),
                _colorBox(AppColors.primary, 'Robot Blue'),
                _colorBox(AppColors.successGreen, 'Success'),
                _colorBox(AppColors.warningOrange, 'Warning'),
                _colorBox(AppColors.dangerRed, 'Danger'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: '2. Buttons'),
            const SizedBox(height: AppSpacing.md),
            GlassButton(onPressed: () {}, child: const Text('Glass Button')),
            const SizedBox(height: AppSpacing.sm),
            GradientButton(onPressed: () {}, text: 'Gradient Button'),
            const SizedBox(height: AppSpacing.sm),
            GlassIconButton(onPressed: () {}, icon: const Icon(AppIcons.robot)),
            const SizedBox(height: AppSpacing.sm),
            const GlassButton(onPressed: null, child: Text('Disabled Button')),
            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: '3. Cards'),
            const SizedBox(height: AppSpacing.md),
            const GlassCard(child: Text('This is a GlassCard')),
            const SizedBox(height: AppSpacing.sm),
            PrimaryActionCard(title: 'Start Robot', icon: AppIcons.robot, onTap: () {}),
            const SizedBox(height: AppSpacing.sm),
            const MetricCard(title: 'Battery Level', value: '87%'),
            const SizedBox(height: AppSpacing.sm),
            const InfoTile(title: 'Network', subtitle: 'Connected to WiFi'),
            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: '4. Indicators'),
            const SizedBox(height: AppSpacing.md),
            const Row(
              children: [
                StatusChip(label: 'Online', color: AppColors.successGreen),
                SizedBox(width: AppSpacing.sm),
                StatusIndicator(color: AppColors.dangerRed),
                SizedBox(width: AppSpacing.lg),
                CircularProgressGlass(),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: '5. Navigation'),
            const SizedBox(height: AppSpacing.md),
            const Text('See CustomAppBar at top. SectionHeaders are used here.'),
            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: '6. Feedback'),
            const SizedBox(height: AppSpacing.md),
            GlassButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                await Future.delayed(const Duration(seconds: 2));
                setState(() => _isLoading = false);
              },
              child: const Text('Trigger Loading Overlay'),
            ),
            const SizedBox(height: AppSpacing.sm),
            const GlassCard(
              child: EmptyStateWidget(message: 'No Data Available', icon: AppIcons.info),
            ),
            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: '7. Animations'),
            const SizedBox(height: AppSpacing.md),
            const AnimatedGlassContainer(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text('Animated Glass Container'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: '8. Responsive Preview'),
            const SizedBox(height: AppSpacing.md),
            Text(
              ResponsiveHelper.isMobile(context) ? 'Mobile View' : (ResponsiveHelper.isTablet(context) ? 'Tablet View' : 'Desktop View'),
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _colorBox(Color color, String name) {
    return Column(
      children: [
        Container(width: 48, height: 48, color: color),
        Text(name, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}




