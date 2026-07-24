import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
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

class ManualControlTabletLayout extends ConsumerWidget {
  const ManualControlTabletLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manualControlProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          const Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CameraPlaceholder(),
                SizedBox(height: AppSpacing.lg),
                SectionHeader(title: 'Movement'),
                SizedBox(height: AppSpacing.sm),
                ControlPad(),
                SizedBox(height: AppSpacing.lg),
                EmergencyStopPanel(),
                SizedBox(height: AppSpacing.lg),
                SectionHeader(title: 'Command Log'),
                SizedBox(height: AppSpacing.sm),
                CommandLogList(),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Right Column
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Arm Control'),
                const SizedBox(height: AppSpacing.sm),
                ...state.servos.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ServoSliderCard(servo: s),
                )),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Active Tools'),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 2.5,
                  children: state.tools.map((t) => ToolControlCard(tool: t)).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Telemetry'),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 2.5,
                  children: state.sensors.map((s) => SensorStatusCard(sensor: s)).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'System Health'),
                const SizedBox(height: AppSpacing.sm),
                const SystemHealthPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
