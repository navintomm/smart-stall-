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

class ManualControlMobileLayout extends StatelessWidget {
  const ManualControlMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CameraPlaceholder(),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Movement'),
          const SizedBox(height: AppSpacing.sm),
          const ControlPad(),
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Command Log'),
          const SizedBox(height: AppSpacing.sm),
          const CommandLogList(),
          const SizedBox(height: AppSpacing.xl),
          const EmergencyStopPanel(),
        ],
      ),
    );
  }
}
