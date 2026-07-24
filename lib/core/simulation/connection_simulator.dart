import 'dart:async';
import 'dart:math';

class ConnectionSimulator {
  final _stateController = StreamController<String>.broadcast();
  final _random = Random();

  Stream<String> get connectionStateStream => _stateController.stream;

  Future<void> connect(String robotId, String type) async {
    _stateController.add('Connecting...');
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    _stateController.add('Connected');
  }

  Future<void> disconnect() async {
    _stateController.add('Disconnecting...');
    await Future.delayed(const Duration(milliseconds: 300));
    _stateController.add('Disconnected');
  }

  void dispose() {
    _stateController.close();
  }
}
