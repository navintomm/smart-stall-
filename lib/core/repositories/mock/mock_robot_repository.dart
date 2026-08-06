import '../robot_repository.dart';
import '../../simulation/robot_simulator.dart';

class MockRobotRepository implements RobotRepository {
  final RobotSimulator _simulator;

  MockRobotRepository(this._simulator);

  @override
  Future<void> sendCommand(String command, Map<String, dynamic> payload) async {
    await _simulator.sendCommand(command, payload);
  }

  @override
  Future<void> moveServo(String servoId, int angle) async {
    await _simulator.sendCommand('MOVE_SERVO', {'id': servoId, 'angle': angle});
  }

  @override
  Future<void> toggleTool(String toolId, bool state) async {
    await _simulator.sendCommand('TOGGLE_TOOL', {'id': toolId, 'state': state});
  }

  @override
  Future<void> triggerEmergencyStop() async {
    await _simulator.sendCommand('EMERGENCY_STOP', {});
  }

  @override
  Future<void> startCleaning() async {
    await _simulator.sendCommand('START_CLEANING', {});
  }

  @override
  Future<void> pauseCleaning() async {
    await _simulator.sendCommand('PAUSE_CLEANING', {});
  }

  @override
  Future<void> resumeCleaning() async {
    await _simulator.sendCommand('RESUME_CLEANING', {});
  }

  @override
  Future<void> stopCleaning() async {
    await _simulator.sendCommand('STOP_CLEANING', {});
  }
}
