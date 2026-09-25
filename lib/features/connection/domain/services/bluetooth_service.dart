import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AppBluetoothService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  final _incomingDataController = StreamController<String>.broadcast();

  Stream<String> get incomingData => _incomingDataController.stream;

  bool get isConnected => _device != null && _device!.isConnected;
  String? get connectedAddress => _device?.remoteId.str;
  String? get connectedName => _device?.advName;

  /// Starts scanning for BLE devices.
  /// Returns a stream of scan results.
  Stream<List<ScanResult>> startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
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
      
      // Discover services to find the Nordic UART Service
      final services = await device.discoverServices();
      
      for (final service in services) {
        // Nordic UART Service UUID
        if (service.uuid.toString().toUpperCase() == '6E400001-B5A3-F393-E0A9-E50E24DCCA9E') {
          for (final characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString().toUpperCase();
            if (uuid == '6E400002-B5A3-F393-E0A9-E50E24DCCA9E') {
              _writeCharacteristic = characteristic;
            } else if (uuid == '6E400003-B5A3-F393-E0A9-E50E24DCCA9E') {
              // Subscribe to TX characteristic to receive data from ESP32
              if (characteristic.properties.notify) {
                await characteristic.setNotifyValue(true);
                characteristic.lastValueStream.listen((value) {
                  final str = utf8.decode(value, allowMalformed: true);
                  _incomingDataController.add(str);
                });
              }
            }
          }
        }
      }

      // Listen for disconnection
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint('BLE Disconnected');
          _cleanupConnection();
        }
      });

      return true;
    } catch (e) {
      debugPrint('Cannot connect to BLE device, exception occurred: $e');
      _cleanupConnection();
      return false;
    }
  }

  void disconnect() {
    _device?.disconnect();
    _cleanupConnection();
  }

  void _cleanupConnection() {
    _device = null;
    _writeCharacteristic = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
  }

  void sendCommand(String command) async {
    if (isConnected && _writeCharacteristic != null) {
      try {
        final data = utf8.encode(command);
        // Write without response is typically preferred for fast UART commands
        await _writeCharacteristic!.write(data, withoutResponse: true);
        debugPrint("BLE Sent: $command");
      } catch (e) {
        debugPrint("BLE send error: $e");
      }
    } else {
      debugPrint("BLE not connected or UART TX not found. Ignored command: $command");
    }
  }
}
