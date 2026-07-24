import 'dart:async';
import '../connection_repository.dart';
import '../../communication/transports/robot_transport.dart';

class HardwareConnectionRepository implements ConnectionRepository {
  final RobotTransport _transport;
  final _stateController = StreamController<String>.broadcast();

  HardwareConnectionRepository(this._transport) {
    _transport.connectionStream.listen((event) {
      _stateController.add(event.status.name);
    });
  }

  @override
  Future<void> connect(String robotId, String connectionType) async {
    await _transport.connect(robotId);
  }

  @override
  Future<void> disconnect() async {
    await _transport.disconnect();
  }

  @override
  Stream<String> get connectionStateStream => _stateController.stream;

  void dispose() {
    _stateController.close();
  }
}
