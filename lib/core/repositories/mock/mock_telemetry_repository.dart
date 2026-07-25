import '../telemetry_repository.dart';
import '../../simulation/telemetry_simulator.dart';
import '../../../shared/models/sensor_data.dart';

class MockTelemetryRepository implements TelemetryRepository {
  final TelemetrySimulator _simulator;

  MockTelemetryRepository(this._simulator);

  @override
  Stream<List<SensorData>> get sensorDataStream => _simulator.sensorStream.map((dataMap) {
    return dataMap.entries
        .where((e) => e.key != 'bat' && e.key != 'bat_v')
        .map((e) => SensorData(id: e.key, name: e.key.toUpperCase(), value: e.value))
        .toList();
  });

  @override
  Stream<Map<String, dynamic>> get batteryLevelStream => _simulator.sensorStream.map((dataMap) {
    return {
      'level': double.tryParse(dataMap['bat']?.replaceAll(' %', '') ?? '100') ?? 100.0,
      'voltage': double.tryParse(dataMap['bat_v']?.replaceAll(' V', '') ?? '12.0') ?? 12.0,
    };
  });
}
