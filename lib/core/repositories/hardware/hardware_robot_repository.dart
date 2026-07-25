import 'dart:async';
import '../robot_repository.dart';
import '../../communication/transports/robot_transport.dart';
import '../../communication/protocol/protocol_codec.dart';
import '../../communication/protocol/models/base_packet.dart';
import '../../communication/protocol/models/packet_type.dart';
import '../../communication/protocol/catalogues/command_catalog.dart';
import '../../communication/protocol/validator/protocol_validator.dart';

class HardwareRobotRepository implements RobotRepository {
  final RobotTransport _transport;
  final ProtocolCodec _codec;
  int _sequenceCounter = 1;

  HardwareRobotRepository(this._transport, this._codec);

  @override
  Future<void> sendCommand(String command, Map<String, dynamic> payload) async {
    // Map string command to V2 integer ID
    int cmdId = 0;
    if (command == 'MOVE_SERVO') cmdId = CommandCatalog.baseRotation.id; // generic map for now
    if (command == 'TOGGLE_TOOL') cmdId = CommandCatalog.waterPump.id;
    if (command == 'EMERGENCY_STOP') cmdId = CommandCatalog.emergencyStop.id;
    if (command == 'STOP') cmdId = CommandCatalog.stop.id;

    final packet = RobotPacket(
      type: PacketType.command,
      commandId: cmdId,
      sequenceNumber: _sequenceCounter++,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      payload: payload,
      crc: ProtocolValidator.calculateChecksum(payload),
    );

    final bytes = _codec.encode(packet);
    await _transport.sendBytes(bytes);
  }

  @override
  Future<void> moveServo(String servoId, int angle) async {
    await sendCommand('MOVE_SERVO', {'id': servoId, 'angle': angle});
  }

  @override
  Future<void> toggleTool(String toolId, bool state) async {
    await sendCommand('TOGGLE_TOOL', {'id': toolId, 'state': state ? 1 : 0});
  }

  @override
  Future<void> triggerEmergencyStop() async {
    await sendCommand('EMERGENCY_STOP', {});
  }
}
