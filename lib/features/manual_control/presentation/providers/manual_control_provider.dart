import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/manual_control_state.dart';
import '../../domain/models/servo_control.dart';
import '../../domain/models/tool_control.dart';
import '../../domain/models/sensor_status.dart';
import '../../domain/models/command_log_entry.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/repositories/robot_repository.dart';

final manualControlProvider = StateNotifierProvider<ManualControlNotifier, ManualControlState>((ref) {
  final repo = ref.watch(robotRepositoryProvider);
    
  final notifier = ManualControlNotifier(repo);

  ref.listen(robotSimulatorProvider.select((s) => s.logStream), (_, stream) {
    stream.listen((newLog) {
      notifier.addLog(newLog);
    });
  });

  return notifier;
});

class ManualControlNotifier extends StateNotifier<ManualControlState> {
  final RobotRepository repo;

  ManualControlNotifier(this.repo) : super(
    ManualControlState(
      servos: ServoControl.placeholders,
      tools: ToolControl.placeholders,
      sensors: SensorStatus.placeholders,
      logs: CommandLogEntry.placeholders,
      emergencyStopEngaged: false,
    )
  );

  void addLog(CommandLogEntry log) {
    state = ManualControlState(
      servos: state.servos,
      tools: state.tools,
      sensors: state.sensors,
      logs: [log, ...state.logs],
      emergencyStopEngaged: state.emergencyStopEngaged,
    );
  }

  Future<void> sendCommand(String command) async {
    await repo.sendCommand(command, {});
  }

  void toggleEmergencyStop() {
    state = ManualControlState(
      servos: state.servos,
      tools: state.tools,
      sensors: state.sensors,
      logs: state.logs,
      emergencyStopEngaged: !state.emergencyStopEngaged,
    );
    sendCommand(state.emergencyStopEngaged ? 'EMERGENCY_STOP' : 'EMERGENCY_RELEASE');
  }
}

