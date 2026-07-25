import 'dart:async';
import '../connection_repository.dart';
import '../../communication/transports/robot_transport.dart';
import '../../communication/models/connection_event.dart';

class HardwareConnectionRepository implements ConnectionRepository {
  final RobotTransport _transport;
  
  HardwareConnectionRepository(this._transport);

  @override
  Stream<String> get connectionStateStream => _transport.connectionStream.map((event) {
    switch (event.status) {
      case ConnectionStatus.connected: return 'Connected';
      case ConnectionStatus.connecting: return 'Connecting';
      case ConnectionStatus.disconnected: return 'Disconnected';
      case ConnectionStatus.scanning: return 'Scanning';
      case ConnectionStatus.error: return 'Error';
    }
  });

  @override
  Future<void> connect(String robotId, String connectionType) async {
    // We treat robotId as IP Address for Wifi
    await _transport.connect(robotId);
  }

  @override
  Future<void> disconnect() async {
    await _transport.disconnect();
  }
}
