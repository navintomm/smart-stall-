import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../connection/presentation/providers/bluetooth_provider.dart';

class SerialLogEntry {
  final DateTime timestamp;
  final String line;
  final bool isSent; // true = outgoing, false = incoming

  const SerialLogEntry({
    required this.timestamp,
    required this.line,
    this.isSent = false,
  });

  String get formatted =>
      '[${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}] '
      '${isSent ? '→' : '←'} $line';
}

class SerialMonitorNotifier extends StateNotifier<List<SerialLogEntry>> {
  StreamSubscription<String>? _dataSub;
  static const int _maxEntries = 500;

  SerialMonitorNotifier(BluetoothStateNotifier btNotifier) : super([]) {
    _dataSub = btNotifier.incomingData.listen((line) {
      _addEntry(SerialLogEntry(
        timestamp: DateTime.now(),
        line: line,
        isSent: false,
      ));
    });
  }

  void addSentCommand(String command) {
    _addEntry(SerialLogEntry(
      timestamp: DateTime.now(),
      line: command,
      isSent: true,
    ));
  }

  void _addEntry(SerialLogEntry entry) {
    final newList = [entry, ...state];
    if (newList.length > _maxEntries) {
      state = newList.sublist(0, _maxEntries);
    } else {
      state = newList;
    }
  }

  void clear() {
    state = [];
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    super.dispose();
  }
}

final serialMonitorProvider =
    StateNotifierProvider<SerialMonitorNotifier, List<SerialLogEntry>>((ref) {
  final btNotifier = ref.watch(bluetoothProvider.notifier);
  return SerialMonitorNotifier(btNotifier);
});
