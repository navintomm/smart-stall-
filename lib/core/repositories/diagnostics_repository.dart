abstract class DiagnosticsRepository {
  Future<Map<String, String>> fetchSystemInfo();
  Stream<Map<String, dynamic>> get networkMetricsStream;
}
