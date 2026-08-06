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
        'bat': '${80 - (_random.nextInt(5))} %',
        'bat_v': '${(12.0 - _random.nextDouble()).toStringAsFixed(1)} V',
        'water': "${60 + _random.nextInt(40)} %",
        'soap': "${30 + _random.nextInt(10)} %",
        'temp': "${35 + _random.nextInt(5)} C",
        'obs': "${50 + _random.nextInt(100)} cm",
        'rssi': "-${60 + _random.nextInt(15)} dBm",
        'clean_state': 'WETTING',
        'clean_step': 'Spraying Water',
        'clean_prog': '${20 + _random.nextInt(5)}',
        'clean_rem': '${40 - _random.nextInt(5)}',
      });
    });
  }

  void dispose() {
    _timer?.cancel();
    _sensorController.close();
  }
}

