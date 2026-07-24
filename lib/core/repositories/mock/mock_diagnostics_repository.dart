import '../diagnostics_repository.dart';
import '../../simulation/diagnostics_simulator.dart';

class MockDiagnosticsRepository implements DiagnosticsRepository {
  final DiagnosticsSimulator _simulator;

  MockDiagnosticsRepository(this._simulator);

  @override
  Future<Map<String, String>> fetchSystemInfo() async {
    return {
      'App Version': '1.0.0 (Build 42)',
      'Protocol Version': 'v3.1 - Binary (Simulated)',
    };
  }

  @override
  Stream<Map<String, dynamic>> get networkMetricsStream => _simulator.networkMetricsStream;
}
