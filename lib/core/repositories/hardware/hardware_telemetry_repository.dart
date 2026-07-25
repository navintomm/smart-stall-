import 'dart:async';
import '../telemetry_repository.dart';
import '../../communication/transports/robot_transport.dart';
import '../../communication/protocol/protocol_codec.dart';
import '../../communication/protocol/models/packet_type.dart';
import '../../../shared/models/sensor_data.dart';
import 'package:flutter/foundation.dart';

class HardwareTelemetryRepository implements TelemetryRepository {
  final RobotTransport _transport;
  final ProtocolCodec _codec;
  
  final _sensorDataController = StreamController<List<SensorData>>.broadcast();
  final _batteryController = StreamController<Map<String, dynamic>>.broadcast();

  HardwareTelemetryRepository(this._transport, this._codec) {
    _transport.receiveStream.listen(_onDataReceived);
  }

  void _onDataReceived(List<int> bytes) {
    try {
      final packet = _codec.decode(bytes);
      if (packet != null && packet.type == PacketType.telemetry) {
        final payload = packet.payload;
        
        // Extract battery
        if (payload.containsKey('bat')) {
          _batteryController.add({'level': (payload['bat'] as num).toDouble()});
        }

        // Map everything else to SensorData list
        final sensors = <SensorData>[];
        if (payload.containsKey('water')) sensors.add(SensorData(id: 'water', name: 'Water Tank', value: '${payload['water']} %'));
        if (payload.containsKey('soap')) sensors.add(SensorData(id: 'soap', name: 'Soap Tank', value: '${payload['soap']} %'));
        if (payload.containsKey('temp')) sensors.add(SensorData(id: 'temp', name: 'Motor Temp', value: '${payload['temp']} C'));
        if (payload.containsKey('rssi')) sensors.add(SensorData(id: 'rssi', name: 'Signal', value: '${payload['rssi']} dBm'));
        
        if (sensors.isNotEmpty) {
          _sensorDataController.add(sensors);
        }
      }
    } catch (e) {
      debugPrint('HardwareTelemetry decode error: $e');
    }
  }

  @override
  Stream<List<SensorData>> get sensorDataStream => _sensorDataController.stream;

  @override
  Stream<Map<String, dynamic>> get batteryLevelStream => _batteryController.stream;
}
