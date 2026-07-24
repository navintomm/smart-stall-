import 'dart:convert';
import '../models/telemetry_packet.dart';
import '../models/diagnostic_packet.dart';

class MessageParser {
  TelemetryPacket? parseTelemetry(List<int> bytes) {
    try {
      final jsonString = utf8.decode(bytes);
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (map.containsKey('telemetry')) {
        return TelemetryPacket(
          timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
          readings: map['telemetry'],
        );
      }
    } catch (_) {}
    return null;
  }

  DiagnosticPacket? parseDiagnostics(List<int> bytes) {
    try {
      final jsonString = utf8.decode(bytes);
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (map.containsKey('diagnostics')) {
        final d = map['diagnostics'];
        return DiagnosticPacket(
          pingMs: d['pingMs'] ?? 0,
          packetLoss: d['packetLoss'] ?? 0.0,
          signalDbm: d['signalDbm'] ?? -100,
        );
      }
    } catch (_) {}
    return null;
  }
}
