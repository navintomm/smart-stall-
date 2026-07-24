import '../../shared/models/sensor_data.dart';

abstract class TelemetryRepository {
  Stream<List<SensorData>> get sensorDataStream;
  Stream<Map<String, dynamic>> get batteryLevelStream;
}
