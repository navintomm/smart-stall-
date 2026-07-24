import 'dart:async';
import 'dart:math';

class DiagnosticsSimulator {
  final _networkMetricsController = StreamController<Map<String, String>>.broadcast();
  Timer? _timer;
  final _random = Random();

  DiagnosticsSimulator() {
    _startSimulation();
  }

  Stream<Map<String, String>> get networkMetricsStream => _networkMetricsController.stream;

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _networkMetricsController.add({
        'Signal Strength': "-${50 + _random.nextInt(20)} dBm",
        'Packet Loss': "${(_random.nextDouble() * 0.5).toStringAsFixed(2)}%",
        'Response Time': "${10 + _random.nextInt(15)}ms",
        'Stability': "${98 + _random.nextInt(2)}.${_random.nextInt(9)}%",
        'Jitter': "${1 + _random.nextInt(4)}ms",
        'Network Health': 'Excellent',
      });
    });
  }

  void dispose() {
    _timer?.cancel();
    _networkMetricsController.close();
  }
}
