import 'dart:async';
import '../diagnostics_repository.dart';
import '../../communication/transports/robot_transport.dart';
import '../../communication/protocol/message_parser.dart';

class HardwareDiagnosticsRepository implements DiagnosticsRepository {
  final RobotTransport _transport;
  final MessageParser _parser;
  final _networkMetricsController = StreamController<Map<String, dynamic>>.broadcast();

  HardwareDiagnosticsRepository(this._transport, this._parser) {
    _transport.receiveStream.listen((bytes) {
      final packet = _parser.parseDiagnostics(bytes);
      if (packet != null) {
        _networkMetricsController.add({
          'Signal Strength': "${packet.signalDbm} dBm",
          'Packet Loss': "${packet.packetLoss}%",
          'Response Time': "${packet.pingMs}ms",
        });
      }
    });
  }

  @override
  Future<Map<String, String>> fetchSystemInfo() async {
    return {
      'App Version': '1.0.0 (Build 42)',
      'Protocol Version': 'v3.1 - Hardware (ESP32)',
    };
  }

  @override
  Stream<Map<String, dynamic>> get networkMetricsStream => _networkMetricsController.stream;
}
