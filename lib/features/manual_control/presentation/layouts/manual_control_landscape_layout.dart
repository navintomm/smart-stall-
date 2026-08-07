import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/display/section_header.dart';
import '../widgets/camera_placeholder.dart';
import '../widgets/control_pad.dart';
import '../widgets/emergency_stop_panel.dart';
import '../widgets/servo_slider_card.dart';
import '../widgets/tool_control_card.dart';
import '../widgets/sensor_status_card.dart';
import '../widgets/command_log_list.dart';
import '../widgets/system_health_panel.dart';
import '../providers/manual_control_provider.dart';

class ManualControlLandscapeLayout extends ConsumerStatefulWidget {
  const ManualControlLandscapeLayout({super.key});

  @override
  ConsumerState<ManualControlLandscapeLayout> createState() => _ManualControlLandscapeLayoutState();
}

class _ManualControlLandscapeLayoutState extends ConsumerState<ManualControlLandscapeLayout> {
  void _showTelemetryBottomSheet(BuildContext context, ref) {
    final state = ref.read(manualControlProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SectionHeader(title: 'Live Telemetry'),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            GridView.count(
                              crossAxisCount: 1,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: AppSpacing.sm,
                              crossAxisSpacing: AppSpacing.sm,
                              childAspectRatio: 2.5,
                              children: state.sensors.map((s) => SensorStatusCard(sensor: s)).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          children: [
                            const SectionHeader(title: 'Command Log'),
                            const SizedBox(height: AppSpacing.sm),
                            const SizedBox(height: 200, child: CommandLogList()),
                            const SizedBox(height: AppSpacing.lg),
                            const SectionHeader(title: 'System Health'),
                            const SizedBox(height: AppSpacing.sm),
                            const SystemHealthPanel(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manualControlProvider);
    
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Side: Camera and Telemetry button
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md, 
                bottom: AppSpacing.md, 
                right: AppSpacing.sm
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(child: CameraPlaceholder()),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _showTelemetryBottomSheet(context, ref),
                    icon: const Icon(Icons.analytics, color: AppColors.primary),
                    label: const Text('View Telemetry'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right Side: Controls and E-Stop
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(
                right: AppSpacing.md, 
                bottom: AppSpacing.md, 
                left: AppSpacing.sm
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionHeader(title: 'Movement'),
                          const SizedBox(height: AppSpacing.sm),
                          const Center(child: ControlPad()),
                          const SizedBox(height: AppSpacing.lg),
                          
                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text('Arm Controls', style: AppTextStyles.titleLarge),
                              tilePadding: EdgeInsets.zero,
                              children: state.servos.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: ServoSliderCard(servo: s),
                              )).toList(),
                            ),
                          ),
                          
                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text('Active Tools', style: AppTextStyles.titleLarge),
                              tilePadding: EdgeInsets.zero,
                              children: [
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: AppSpacing.sm,
                                  crossAxisSpacing: AppSpacing.sm,
                                  childAspectRatio: 2.5,
                                  children: state.tools.map((t) => ToolControlCard(tool: t)).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const EmergencyStopPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
