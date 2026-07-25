import 'dart:convert';
import '../models/base_packet.dart';
import '../catalogues/command_catalog.dart';

class ProtocolValidator {
  static const int maxPayloadSize = 4096;

  static bool validateLength(String rawPacket) {
    return rawPacket.length <= maxPayloadSize;
  }

  static bool validateRequiredFields(Map<String, dynamic> json) {
    return json.containsKey('ver') &&
           json.containsKey('type') &&
           json.containsKey('seq') &&
           json.containsKey('ts') &&
           json.containsKey('data') &&
           json.containsKey('crc');
  }

  static bool validateChecksum(Map<String, dynamic> json, int declaredCrc) {
    // Basic summation CRC logic as placeholder
    final dataStr = jsonEncode(json['data'] ?? {});
    int sum = 0;
    for (int i = 0; i < dataStr.length; i++) {
      sum += dataStr.codeUnitAt(i);
    }
    return (sum % 256) == declaredCrc;
  }
  
  static int calculateChecksum(Map<String, dynamic> payload) {
    final dataStr = jsonEncode(payload);
    int sum = 0;
    for (int i = 0; i < dataStr.length; i++) {
      sum += dataStr.codeUnitAt(i);
    }
    return sum % 256;
  }

  static String? validateCommandPayload(RobotPacket packet) {
    if (packet.commandId <= 0) return 'Missing commandId';
    
    final cmdDef = CommandCatalog.getById(packet.commandId);
    if (cmdDef == null) return 'Unknown Command ID: ${packet.commandId}';

    for (var key in cmdDef.requiredPayloadKeys) {
      if (!packet.payload.containsKey(key)) {
        return 'Missing required payload key: $key';
      }
    }
    return null; // Valid
  }
}

