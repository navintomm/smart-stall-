import 'dart:async';
import '../telemetry_repository.dart';
import '../../communication/transports/robot_transport.dart';
import '../../communication/protocol/message_parser.dart';
import '../../../shared/models/sensor_data.dart';

class HardwareTelemetryRepository implements TelemetryRepository {
  final RobotTransport _transport;
  final MessageParser _parser;
  final _sensorController = StreamController<List<SensorData>>.broadcast();

  HardwareTelemetryRepository(this._transport, this._parser) {
    _transport.receiveStream.listen((bytes) {
      final packet = _parser.parseTelemetry(bytes);
      if (packet != null) {
        final list = packet.readings.entries
            .map((e) => SensorData(id: e.key, name: e.key, value: e.value.toString()))
            .toList();
        _sensorController.add(list);
      }
    });
  }

  @override
  Stream<List<SensorData>> get sensorDataStream => _sensorController.stream;

  @override
  Stream<Map<String, dynamic>> get batteryLevelStream => const Stream.empty();
}
