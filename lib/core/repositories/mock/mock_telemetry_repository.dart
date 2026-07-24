import '../telemetry_repository.dart';
import '../../simulation/telemetry_simulator.dart';
import '../../../shared/models/sensor_data.dart';

class MockTelemetryRepository implements TelemetryRepository {
  final TelemetrySimulator _simulator;

  MockTelemetryRepository(this._simulator);

  @override
  Stream<List<SensorData>> get sensorDataStream => _simulator.sensorStream.map((dataMap) {
    return dataMap.entries.map((e) => SensorData(id: e.key, name: e.key, value: e.value)).toList();
  });

  @override
  Stream<Map<String, dynamic>> get batteryLevelStream => const Stream.empty();
}
