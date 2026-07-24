import 'dart:async';
import '../models/connection_event.dart';

abstract class RobotTransport {
  Future<void> connect(String targetId);
  Future<void> disconnect();
  Future<void> sendBytes(List<int> payload);
  Stream<List<int>> get receiveStream;
  Stream<ConnectionEvent> get connectionStream;
}
