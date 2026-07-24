import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/section_header.dart';
import '../../domain/models/servo_control.dart';
import '../../domain/models/tool_control.dart';
import '../../domain/models/sensor_status.dart';
import '../widgets/camera_placeholder.dart';
import '../widgets/control_pad.dart';
import '../widgets/emergency_stop_panel.dart';
import '../widgets/servo_slider_card.dart';
import '../widgets/tool_control_card.dart';
import '../widgets/sensor_status_card.dart';
import '../widgets/command_log_list.dart';
import '../widgets/system_health_panel.dart';

class ManualControlTabletLayout extends StatelessWidget {
  const ManualControlTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                SectionHeader(title: 'Command Log'),
                SizedBox(height: AppSpacing.sm),
                CommandLogList(),
                SizedBox(height: AppSpacing.lg),
                EmergencyStopPanel(),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Robotic Arm'),
                const SizedBox(height: AppSpacing.sm),
                ...ServoControl.placeholders.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ServoSliderCard(servo: s),
                )),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Tools'),
                const SizedBox(height: AppSpacing.sm),
                ...ToolControl.placeholders.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ToolControlCard(tool: t),
                )),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Sensors'),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.5,
                  children: SensorStatus.placeholders.map((s) => SensorStatusCard(sensor: s)).toList(),
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
