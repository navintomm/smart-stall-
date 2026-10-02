import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// Bluetooth Classic (SPP) service for HC-05 modules and similar.
class BluetoothClassicService {
  BluetoothConnection? _connection;
  final _incomingDataController = StreamController<String>.broadcast();
  final _connectionStateController = StreamController<String>.broadcast();

  /// Line-assembly buffer: accumulates partial data and emits only on '\n'.
  String _lineBuffer = '';

  Stream<String> get incomingData => _incomingDataController.stream;
  Stream<String> get connectionStateStream => _connectionStateController.stream;

  bool get isConnected => _connection != null && _connection!.isConnected;

  /// Get paired (bonded) Bluetooth Classic devices from the system.
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      return [];
    }
  }

  /// Connect to a Bluetooth Classic device by address.
  Future<bool> connect(String address) async {
    try {
      _connectionStateController.add('CONNECTING');
      _lineBuffer = '';

      _connection = await BluetoothConnection.toAddress(address);
      debugPrint('BT Classic: Connected to $address');
      _connectionStateController.add('CONNECTED');

      // Listen for incoming data
      _connection!.input?.listen(
        (Uint8List data) {
          final str = utf8.decode(data, allowMalformed: true);
          _assembleLines(str);
        },
        onDone: () {
          debugPrint('BT Classic: Disconnected');
          _connectionStateController.add('DISCONNECTED');
          _cleanupConnection();
        },
        onError: (e) {
          debugPrint('BT Classic: Error: $e');
          _connectionStateController.add('DISCONNECTED');
          _cleanupConnection();
        },
      );

      return true;
    } catch (e) {
      debugPrint('BT Classic: Cannot connect, exception: $e');
      _connectionStateController.add('DISCONNECTED');
      _cleanupConnection();
      return false;
    }
  }

  /// Accumulates incoming data fragments and emits complete lines on '\n'.
  void _assembleLines(String chunk) {
    _lineBuffer += chunk;
    while (_lineBuffer.contains('\n')) {
      final idx = _lineBuffer.indexOf('\n');
      final line = _lineBuffer.substring(0, idx).replaceAll('\r', '').trim();
      _lineBuffer = _lineBuffer.substring(idx + 1);
      if (line.isNotEmpty) {
        _incomingDataController.add(line);
      }
    }
  }

  void disconnect() {
    _connection?.dispose();
    _connectionStateController.add('DISCONNECTED');
    _cleanupConnection();
  }

  void _cleanupConnection() {
    _connection = null;
    _lineBuffer = '';
  }

  /// Send a command over Bluetooth Classic.
  /// Inter-send delay during playback: 10ms between points (caller handles delay).
  Future<void> sendCommand(String command) async {
    if (isConnected && _connection != null) {
      try {
        _connection!.output.add(utf8.encode(command));
        await _connection!.output.allSent;
        debugPrint("BT Classic Sent: $command");
      } catch (e) {
        debugPrint("BT Classic send error: $e");
      }
    } else {
      debugPrint("BT Classic not connected. Ignored command: $command");
    }
  }

  void dispose() {
    _connection?.dispose();
    _incomingDataController.close();
    _connectionStateController.close();
  }
}
