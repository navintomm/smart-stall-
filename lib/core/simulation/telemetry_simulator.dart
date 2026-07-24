import 'dart:async';
import 'dart:math';

class TelemetrySimulator {
  final _sensorController = StreamController<Map<String, String>>.broadcast();
  Timer? _timer;
  final _random = Random();

  TelemetrySimulator() {
    _startSimulation();
  }

  Stream<Map<String, String>> get sensorStream => _sensorController.stream;

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _sensorController.add({
        'Water Tank': "${60 + _random.nextInt(40)}%",
        'Soap Tank': "${30 + _random.nextInt(10)}%",
        'Brush Wear': "${8 + _random.nextInt(5)}%",
        'Pump Flow': "${(1.0 + _random.nextDouble() * 0.5).toStringAsFixed(1)} L/m",
      });
    });
  }

  void dispose() {
    _timer?.cancel();
    _sensorController.close();
  }
}

