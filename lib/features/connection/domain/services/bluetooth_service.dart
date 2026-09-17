import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  BluetoothConnection? _connection;
  String? _connectedAddress;
  bool get isConnected => _connection?.isConnected ?? false;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await FlutterBluetoothSerial.instance.getBondedDevices();
  }

  Future<bool> connect(String address) async {
    try {
      _connection = await BluetoothConnection.toAddress(address);
      _connectedAddress = address;
      
      _connection!.input!.listen((Uint8List data) {
        // Handle incoming data if needed
        print('Data incoming: ${ascii.decode(data)}');
      }).onDone(() {
        print('Disconnected by remote request');
        _connection = null;
        _connectedAddress = null;
      });

      return true;
    } catch (e) {
      print('Cannot connect, exception occurred: $e');
      return false;
    }
  }

  void disconnect() {
    _connection?.dispose();
    _connection = null;
    _connectedAddress = null;
  }

  void sendCommand(String command) {
    if (isConnected) {
      try {
        _connection!.output.add(ascii.encode(command));
        _connection!.output.allSent; // await not necessary, we just want it to flush
        print("Bluetooth Sent: $command");
      } catch (e) {
        print("Bluetooth send error: $e");
      }
    } else {
      print("Bluetooth not connected. Ignored command: $command");
    }
  }
}
