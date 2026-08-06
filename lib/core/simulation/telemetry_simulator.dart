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
        'clean_progress': '${20 + _random.nextInt(5)}',
        'clean_remaining': '${40 - _random.nextInt(5)}',
        'clean_elapsed': '${20 + _random.nextInt(5)}',
        'clean_cycle': '1',
        'abort_reason': '',
        'cam_status': 'OK',
        'cam_fps': '${28 + _random.nextInt(4)}',
        'marker_id': '1',
        'marker_dist': '${0.4 + _random.nextDouble() * 0.2}',
        'marker_conf': '${0.95 + _random.nextDouble() * 0.04}',
        'loc_state': 'READY',
        'align_score': '${96 + _random.nextInt(4)}',
        'pose_x': '${-0.05 + _random.nextDouble() * 0.1}',
        'pose_y': '${-0.05 + _random.nextDouble() * 0.1}',
        'pose_z': '${0.4 + _random.nextDouble() * 0.2}',
        'pose_roll': '${_random.nextDouble() * 2}',
        'pose_pitch': '${_random.nextDouble() * 2}',
        'pose_yaw': '${_random.nextDouble() * 2}',
        'last_det_time': '${DateTime.now().millisecondsSinceEpoch}',
        'mission_state': 'NAVIGATING',
        'current_waypoint': '100',
        'target_waypoint': '101',
        'navigation_progress': '${20 + _random.nextInt(5)}',
        'distance_remaining': '${2.5 - _random.nextDouble()}',
        'mission_time': '${120 + _random.nextInt(10)}',
        'mission_count': '3',
        'nav_state': 'APPROACHING',
      });
    });
  }

  void dispose() {
    _timer?.cancel();
    _sensorController.close();
  }
}

