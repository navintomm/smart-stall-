import 'dart:async';
import '../robot_repository.dart';
import '../../communication/transports/robot_transport.dart';
import '../../communication/protocol/protocol_codec.dart';
import '../../communication/protocol/models/base_packet.dart';
import '../../communication/protocol/models/packet_type.dart';
import '../../communication/protocol/catalogues/command_catalog.dart';
import '../../communication/protocol/validator/protocol_validator.dart';
import '../../../features/auto_cleaning/domain/models/cleaning_profile.dart';

class HardwareRobotRepository implements RobotRepository {
  final RobotTransport _transport;
  final ProtocolCodec _codec;
  int _sequenceCounter = 1;

  HardwareRobotRepository(this._transport, this._codec);

  @override
  Future<void> sendCommand(String command, Map<String, dynamic> payload) async {
    int cmdId = 0;
    Map<String, dynamic> finalPayload = Map.from(payload);

    if (command == 'EFFECTOR_SPRAY_ON') {
      cmdId = CommandCatalog.waterPump.id;
      finalPayload = {'state': 1};
    } else if (command == 'EFFECTOR_SPRAY_OFF') {
      cmdId = CommandCatalog.waterPump.id;
      finalPayload = {'state': 0};
    } else if (command == 'EFFECTOR_BRUSH_ON') {
      cmdId = CommandCatalog.brushMotor.id;
      finalPayload = {'state': 1};
    } else if (command == 'EFFECTOR_BRUSH_OFF') {
      cmdId = CommandCatalog.brushMotor.id;
      finalPayload = {'state': 0};
    } else if (command == 'LINEAR_UP') {
      cmdId = CommandCatalog.shoulder.id;
      finalPayload = {'angle': 90};
    } else if (command == 'LINEAR_DOWN') {
      cmdId = CommandCatalog.shoulder.id;
      finalPayload = {'angle': 0};
    } else if (command.startsWith('SET_SPEED:')) {
      final speedVal = int.tryParse(command.split(':').last) ?? 50;
      cmdId = CommandCatalog.brushRotation.id;
      finalPayload = {'speed': speedVal};
    } else {
      try {
        cmdId = CommandCatalog.allCommands.firstWhere((cmd) => cmd.name == command).id;
      } catch (_) {
        if (command == 'MOVE_SERVO') {
          final servoId = finalPayload['id'] as String?;
          if (servoId == 'base') {
            cmdId = CommandCatalog.baseRotation.id;
          } else if (servoId == 'shoulder') {
            cmdId = CommandCatalog.shoulder.id;
          } else if (servoId == 'elbow') {
            cmdId = CommandCatalog.elbow.id;
          } else if (servoId == 'wrist') {
            cmdId = CommandCatalog.wrist.id;
          } else {
            cmdId = CommandCatalog.baseRotation.id; // fallback
          }
        } else if (command == 'TOGGLE_TOOL') {
          cmdId = CommandCatalog.waterPump.id;
        }
      }
    }

    // Default speed for movement commands if not provided
    if (['MOVE_FORWARD', 'MOVE_BACKWARD', 'TURN_LEFT', 'TURN_RIGHT'].contains(command) &&
        !finalPayload.containsKey('speed')) {
      finalPayload['speed'] = 50;
    }

    final packet = RobotPacket(
      type: PacketType.command,
      commandId: cmdId,
      sequenceNumber: _sequenceCounter++,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      payload: finalPayload,
      crc: ProtocolValidator.calculateChecksum(finalPayload),
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

  @override
  Future<void> startCleaning() async {
    await sendCommand('START_CLEANING', {});
  }

  @override
  Future<void> startCleaningWithProfile(CleaningProfile profile) async {
    await sendCommand('START_CLEANING_PROFILE', {
      'severity': profile.severity.index,
      'water_ml': profile.waterVolumeMl,
      'pump_ms': profile.pumpDurationMs,
      'brush_ms': profile.brushDurationMs,
      'routine': profile.routineId,
    });
  }

  @override
  Future<void> pauseCleaning() async {
    await sendCommand('PAUSE_CLEANING', {});
  }

  @override
  Future<void> resumeCleaning() async {
    await sendCommand('RESUME_CLEANING', {});
  }

  @override
  Future<void> stopCleaning() async {
    await sendCommand('STOP_CLEANING', {});
  }
}
