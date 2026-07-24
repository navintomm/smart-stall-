import 'dart:async';
import 'robot_transport.dart';
import '../models/connection_event.dart';

class BluetoothTransport implements RobotTransport {
  final _receiveController = StreamController<List<int>>.broadcast();
  final _connectionController = StreamController<ConnectionEvent>.broadcast();

  @override
  Future<void> connect(String targetId) async {
    _connectionController.add(const ConnectionEvent(status: ConnectionStatus.scanning));
    await Future.delayed(const Duration(seconds: 1));
    _connectionController.add(const ConnectionEvent(status: ConnectionStatus.connecting));
    await Future.delayed(const Duration(seconds: 1));
    _connectionController.add(const ConnectionEvent(status: ConnectionStatus.connected));
  }

  @override
  Future<void> disconnect() async {
    _connectionController.add(const ConnectionEvent(status: ConnectionStatus.disconnected));
  }

  @override
  Future<void> sendBytes(List<int> payload) async {
    // Placeholder: Log bytes sent over Bluetooth
    // print('BT SEND: $payload');
  }

  @override
  Stream<List<int>> get receiveStream => _receiveController.stream;

  @override
  Stream<ConnectionEvent> get connectionStream => _connectionController.stream;
}
