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
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Manual Control',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Maintenance banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withOpacity(0.08),
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(color: AppColors.dangerRed.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(AppIcons.warning, color: AppColors.dangerRed, size: 14),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Maintenance & Testing Mode — for authorised technicians only.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.dangerRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── LEFT ZONE: Camera ────────────────────────────────────
                    Expanded(
                      flex: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(
                            child: CameraPlaceholder(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () {}, // Telemetry bottom sheet
                            icon: const Icon(Icons.analytics, color: AppColors.primary),
                            label: const Text('View Telemetry'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),

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
                            const SizedBox(height: AppSpacing.md),
                            JoystickController(
                              size: 160,
                              onDirectionChanged: (offset) {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),

                    // ── RIGHT ZONE: Arm & Tools ──────────────────────────────
                    Expanded(
                      flex: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                                    ...state.servos.map((s) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
                                        child: ServoSliderCard(servo: s),
                                      ),
                                    )),
                                    
                                    const SizedBox(height: AppSpacing.xs),
                                    Text('Active Tools', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                    ...state.tools.map((t) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
                                        child: ToolControlCard(tool: t),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const EmergencyStopPanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
