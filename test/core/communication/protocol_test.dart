import 'package:flutter_test/flutter_test.dart';
import 'package:smartstall_operator/core/communication/protocol/models/base_packet.dart';
import 'package:smartstall_operator/core/communication/protocol/models/packet_type.dart';
import 'package:smartstall_operator/core/communication/protocol/catalogues/command_catalog.dart';
import 'package:smartstall_operator/core/communication/protocol/validator/protocol_validator.dart';
import 'package:smartstall_operator/core/communication/protocol/protocol_codec.dart';

void main() {
  group('ProtocolCodec & Models', () {
    final codec = ProtocolCodec();

    test('Encode and Decode a Command Packet', () {
      final packet = RobotPacket(
        type: PacketType.command,
        commandId: CommandCatalog.moveForward.id,
        sequenceNumber: 1,
        timestamp: 1698765432000,
        payload: {'speed': 50},
        crc: ProtocolValidator.calculateChecksum({'speed': 50}),
      );

      final bytes = codec.encode(packet);
      final decoded = codec.decode(bytes);

      expect(decoded, isNotNull);
      expect(decoded!.type, PacketType.command);
      expect(decoded.commandId, CommandCatalog.moveForward.id);
      expect(decoded.sequenceNumber, 1);
      expect(decoded.payload['speed'], 50);
      expect(decoded.protocolVersion, '2.0');
    });

    test('Decode Malformed Packet', () {
      final bytes = [123, 34, 118, 101]; // Partial JSON {"ve
      final decoded = codec.decode(bytes);
      expect(decoded, isNull);
    });
  });

  group('ProtocolValidator', () {
    test('Validate Length', () {
      const shortStr = '{"a": 1}';
      expect(ProtocolValidator.validateLength(shortStr), isTrue);
      
      final longStr = 'a' * 5000;
      expect(ProtocolValidator.validateLength(longStr), isFalse);
    });

    test('Validate Required Fields', () {
      final validJson = {
        'ver': '2.0',
        'type': 'command',
        'cmdId': 101,
        'seq': 1,
        'ts': 1000,
        'data': {},
        'crc': 0
      };
      expect(ProtocolValidator.validateRequiredFields(validJson), isTrue);

      final invalidJson = {'ver': '2.0'}; // Missing type, seq, etc.
      expect(ProtocolValidator.validateRequiredFields(invalidJson), isFalse);
    });

    test('Validate Command Payload (Missing Args)', () {
      final packet = RobotPacket(
        type: PacketType.command,
        commandId: CommandCatalog.moveForward.id, // requires 'speed'
        sequenceNumber: 1,
        timestamp: 1000,
        payload: {}, // Missing 'speed'
      );

      final error = ProtocolValidator.validateCommandPayload(packet);
      expect(error, contains('Missing required payload key'));
    });

    test('Validate Command Payload (Unknown Command)', () {
      const packet = RobotPacket(
        type: PacketType.command,
        commandId: 9999, // Doesn't exist
        sequenceNumber: 1,
        timestamp: 1000,
        payload: {},
      );

      final error = ProtocolValidator.validateCommandPayload(packet);
      expect(error, contains('Unknown Command ID'));
    });
  });
}
