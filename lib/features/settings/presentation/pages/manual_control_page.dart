import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../features/manual_control/presentation/widgets/camera_placeholder.dart';
import '../../../../features/manual_control/presentation/widgets/joystick_controller.dart';
import '../../../../features/manual_control/presentation/widgets/servo_slider_card.dart';
import '../../../../features/manual_control/presentation/widgets/tool_control_card.dart';
import '../../../../features/manual_control/presentation/widgets/emergency_stop_panel.dart';
import '../../../../features/manual_control/presentation/providers/manual_control_provider.dart';

class ManualControlPage extends ConsumerWidget {
  const ManualControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manualControlProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── LEFT ZONE: Camera & Title ────────────────────────────────────
              Expanded(
                flex: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar (Back Button + Title)
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Manual Control',
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Maintenance Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed.withOpacity(0.08),
                        borderRadius: AppRadius.smallRadius,
                        border: Border.all(color: AppColors.dangerRed.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(AppIcons.warning, color: AppColors.dangerRed, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Maintenance Mode',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.dangerRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Expanded(
                      child: CameraPlaceholder(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () {}, // Telemetry bottom sheet
                      icon: const Icon(Icons.analytics, color: AppColors.primary, size: 16),
                      label: const Text('View Telemetry', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // ── CENTER ZONE: Joystick ────────────────────────────────
              Expanded(
                flex: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Movement Control',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: JoystickController(
                              size: 200,
                              onDirectionChanged: (offset) {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // ── RIGHT ZONE: Arm & Tools ──────────────────────────────
              Expanded(
                flex: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderLight, width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Joint Control', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            if (state.servos.isNotEmpty) ...state.servos.map((s) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: ServoSliderCard(servo: s),
                              ),
                            )),
                            if (state.servos.isEmpty) const Expanded(child: Center(child: Text('No Servos'))),
                            
                            const SizedBox(height: 2),
                            Text('Active Tools', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            if (state.tools.isNotEmpty) ...state.tools.map((t) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: ToolControlCard(tool: t),
                              ),
                            )),
                            if (state.tools.isEmpty) const Expanded(child: Center(child: Text('No Tools'))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const EmergencyStopPanel(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
