import '../robot_repository.dart';
import '../../communication/transports/robot_transport.dart';
import '../../communication/protocol/command_encoder.dart';
import '../../communication/models/robot_command.dart';

class HardwareRobotRepository implements RobotRepository {
  final RobotTransport _transport;
  final CommandEncoder _encoder;

  HardwareRobotRepository(this._transport, this._encoder);

  @override
  Future<void> sendCommand(String command, Map<String, dynamic> payload) async {
    final robotCommand = RobotCommand(action: command, payload: payload);
    final bytes = _encoder.encode(robotCommand);
    await _transport.sendBytes(bytes);
  }

  @override
  Future<void> moveServo(String servoId, int angle) async {
    await sendCommand('MOVE_SERVO', {'id': servoId, 'angle': angle});
  }

  @override
  Future<void> toggleTool(String toolId, bool state) async {
    await sendCommand('TOGGLE_TOOL', {'id': toolId, 'state': state});
  }

  @override
  Future<void> triggerEmergencyStop() async {
    await sendCommand('EMERGENCY_STOP', {});
  }
}
