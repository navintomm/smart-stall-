import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE service with proper line-assembly buffer, chunked writes, and scan debounce.
class AppBluetoothService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  final _incomingDataController = StreamController<String>.broadcast();
  final _connectionStateController = StreamController<String>.broadcast();

  /// Line-assembly buffer: accumulates partial BLE chunks and emits only on '\n'.
  String _lineBuffer = '';

  /// Scan debounce timestamp
  DateTime? _lastScanTime;

  Stream<String> get incomingData => _incomingDataController.stream;
  Stream<String> get connectionStateStream => _connectionStateController.stream;

  bool get isConnected => _device != null && _device!.isConnected;
  String? get connectedAddress => _device?.remoteId.str;
  String? get connectedName => _device?.advName;

  /// Starts scanning for BLE devices with a 5-second debounce.
  Stream<List<ScanResult>> startScan() {
    // Debounce: ignore re-scan requests within 5 seconds
    if (_lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!).inSeconds < 5) {
      debugPrint('[BLE] Scan debounced — too soon since last scan');
      return FlutterBluePlus.scanResults;
    }
    _lastScanTime = DateTime.now();

    // Stop any ongoing scan before starting a new one
    FlutterBluePlus.stopScan();

    // Small delay to let Android clear the previous scan
    Future.delayed(const Duration(milliseconds: 300), () {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    });
    return FlutterBluePlus.scanResults;
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  /// Connects to a specific BLE device by its MAC address.
  Future<bool> connect(String remoteIdStr) async {
    try {
      final device = BluetoothDevice.fromId(remoteIdStr);
      await device.connect(autoConnect: false);
      _device = device;
      _lineBuffer = '';

      // Discover services to find UART-like Services
      final services = await device.discoverServices();

      for (final service in services) {
        final serviceUuid = service.uuid.toString().toUpperCase();

        // 1. Nordic UART Service
        if (serviceUuid.contains('6E400001-B5A3-F393-E0A9-E50E24DCCA9E')) {
          for (final characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString().toUpperCase();
            if (uuid.contains('6E400002-B5A3-F393-E0A9-E50E24DCCA9E')) {
              _writeCharacteristic = characteristic;
            } else if (uuid.contains('6E400003-B5A3-F393-E0A9-E50E24DCCA9E')) {
              await _subscribeToNotify(characteristic);
            }
          }
        }
        // 2. HM-10 / JDY-08 Generic UART (FFE0)
        else if (serviceUuid.contains('FFE0') || serviceUuid.contains('0000FFE0')) {
          for (final characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString().toUpperCase();
            if (uuid.contains('FFE1') || uuid.contains('0000FFE1')) {
              _writeCharacteristic = characteristic;
              await _subscribeToNotify(characteristic);
            }
          }
        }
        // 3. Last Resort Fallback
        else {
          for (final characteristic in service.characteristics) {
            if (_writeCharacteristic == null &&
                (characteristic.properties.write ||
                    characteristic.properties.writeWithoutResponse)) {
              _writeCharacteristic = characteristic;
            }
            if (characteristic.properties.notify) {
              try {
                await _subscribeToNotify(characteristic);
              } catch (_) {}
            }
          }
        }
      }

      // Listen for disconnection
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription =
          device.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint('BLE Disconnected');
          _connectionStateController.add('DISCONNECTED');
          _cleanupConnection();
        }
      });

      _connectionStateController.add('CONNECTED');
      return true;
    } catch (e) {
      debugPrint('Cannot connect to BLE device, exception occurred: $e');
      _cleanupConnection();
      return false;
    }
  }

  /// Subscribe to a notifiable characteristic with line-assembly buffering.
  Future<void> _subscribeToNotify(BluetoothCharacteristic characteristic) async {
    if (!characteristic.properties.notify) return;
    await characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((value) {
      final str = utf8.decode(value, allowMalformed: true);
      _assembleLines(str);
    });
  }

  /// Accumulates incoming BLE fragments and emits complete lines on '\n'.
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
    _device?.disconnect();
    _connectionStateController.add('DISCONNECTED');
    _cleanupConnection();
  }

  void _cleanupConnection() {
    _device = null;
    _writeCharacteristic = null;
    _lineBuffer = '';
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
  }

  /// Send a command, chunked at 20 bytes with 30ms delay between chunks.
  Future<void> sendCommand(String command) async {
    if (isConnected && _writeCharacteristic != null) {
      try {
        final data = utf8.encode(command);
        // Chunk at 20 bytes for BLE MTU safety
        for (int i = 0; i < data.length; i += 20) {
          final end = (i + 20 > data.length) ? data.length : i + 20;
          final chunk = data.sublist(i, end);
          await _writeCharacteristic!.write(chunk, withoutResponse: true);
          if (end < data.length) {
            await Future.delayed(const Duration(milliseconds: 30));
          }
        }
        debugPrint("BLE Sent: $command");
      } catch (e) {
        debugPrint("BLE send error: $e");
      }
    } else {
      debugPrint(
          "BLE not connected or UART TX not found. Ignored command: $command");
    }
  }

  void dispose() {
    _incomingDataController.close();
    _connectionStateController.close();
  }
}
