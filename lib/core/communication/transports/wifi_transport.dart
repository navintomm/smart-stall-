import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'robot_transport.dart';
import '../models/connection_event.dart';

class WifiTransport implements RobotTransport {
  Socket? _socket;
  final _receiveController = StreamController<List<int>>.broadcast();
  final _connectionController = StreamController<ConnectionEvent>.broadcast();
  
  bool _isConnected = false;
  
  // Buffer for incoming TCP chunks
  final List<int> _buffer = [];

  @override
  Future<void> connect(String targetId) async {
    if (_isConnected) return;
    
    _connectionController.add(const ConnectionEvent(status: ConnectionStatus.connecting));
    
    try {
      // Assuming targetId is an IP address like '192.168.4.1'
      _socket = await Socket.connect(targetId, 8888, timeout: const Duration(seconds: 5));
      _isConnected = true;
      _connectionController.add(const ConnectionEvent(status: ConnectionStatus.connected));
      
      _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('WIFI CONNECT ERROR: $e');
      _connectionController.add(const ConnectionEvent(status: ConnectionStatus.error));
      _isConnected = false;
    }
  }

  void _onData(List<int> data) {
    // Append to buffer
    _buffer.addAll(data);
    
    // Look for newline character (10) as delimiter
    while (true) {
      final index = _buffer.indexOf(10); // 10 is '\n'
      if (index == -1) break; // Incomplete packet, wait for more data
      
      // Extract the complete packet (including newline)
      final packetBytes = _buffer.sublist(0, index + 1);
      _receiveController.add(packetBytes);
      
      // Remove the processed packet from the buffer
      _buffer.removeRange(0, index + 1);
    }
  }

  void _onError(error) {
    debugPrint('WIFI SOCKET ERROR: $error');
    disconnect();
  }

  void _onDone() {
    debugPrint('WIFI SOCKET DONE');
    disconnect();
  }

  @override
  Future<void> disconnect() async {
    if (!_isConnected) return;
    _isConnected = false;
    _socket?.destroy();
    _socket = null;
    _buffer.clear();
    _connectionController.add(const ConnectionEvent(status: ConnectionStatus.disconnected));
  }

  @override
  Future<void> sendBytes(List<int> payload) async {
    if (!_isConnected || _socket == null) {
      debugPrint('WIFI SEND ERROR: Not connected');
      return;
    }
    
    try {
      _socket!.add(payload);
      await _socket!.flush();
    } catch (e) {
      debugPrint('WIFI WRITE ERROR: $e');
      disconnect();
    }
  }

  @override
  Stream<List<int>> get receiveStream => _receiveController.stream;

  @override
  Stream<ConnectionEvent> get connectionStream => _connectionController.stream;
}

