import 'dart:async';
import '../models/connection_event.dart';

class ConnectionMonitor {
  final _stateController = StreamController<ConnectionStatus>.broadcast();
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;

  Stream<ConnectionStatus> get statusStream => _stateController.stream;
  ConnectionStatus get currentStatus => _currentStatus;

  void updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _stateController.add(status);
    }
  }

  void dispose() {
    _stateController.close();
  }
}
