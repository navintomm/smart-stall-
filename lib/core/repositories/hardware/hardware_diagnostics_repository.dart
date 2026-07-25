import 'dart:async';
import '../diagnostics_repository.dart';
import '../../communication/transports/robot_transport.dart';
import '../../communication/protocol/protocol_codec.dart';
import '../../communication/protocol/models/packet_type.dart';
import 'package:flutter/foundation.dart';

class HardwareDiagnosticsRepository implements DiagnosticsRepository {
  final RobotTransport _transport;
  final ProtocolCodec _codec;
  
  final _networkController = StreamController<Map<String, dynamic>>.broadcast();

  HardwareDiagnosticsRepository(this._transport, this._codec) {
    _transport.receiveStream.listen(_onDataReceived);
  }

  void _onDataReceived(List<int> bytes) {
    try {
      final packet = _codec.decode(bytes);
      if (packet != null && packet.type == PacketType.diagnostics) {
        final payload = packet.payload;
        if (payload.containsKey('rssi') || payload.containsKey('latency')) {
          _networkController.add({
            'signal_strength': payload['rssi'] ?? -70,
            'latency': payload['latency'] ?? 45,
            'packet_loss': payload['loss'] ?? 0.0,
          });
        }
      }
    } catch (e) {
      debugPrint('HardwareDiagnostics decode error: $e');
    }
  }

  @override
  Future<Map<String, String>> fetchSystemInfo() async {
    // In hardware mode, this could send a specific command requesting firmware versions.
    // For now, we return placeholders since we don't have the ESP32 hooked up to respond.
    return {
      'Firmware Version': 'v2.0.0',
      'Hardware Rev': 'Rev C',
      'Uptime': 'Unknown',
      'IP Address': '192.168.4.1',
    };
  }

  @override
  Stream<Map<String, dynamic>> get networkMetricsStream => _networkController.stream;
}
