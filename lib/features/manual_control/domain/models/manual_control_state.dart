import 'servo_control.dart';
import 'tool_control.dart';
import 'sensor_status.dart';
import 'command_log_entry.dart';

class ManualControlState {
  final List<ServoControl> servos;
  final List<ToolControl> tools;
  final List<SensorStatus> sensors;
  final List<CommandLogEntry> logs;
  final bool emergencyStopEngaged;
  final bool isLoading;

  const ManualControlState({
    this.servos = const [],
    this.tools = const [],
    this.sensors = const [],
    this.logs = const [],
    this.emergencyStopEngaged = false,
    this.isLoading = false,
  });
}
