import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/services/bluetooth_service.dart';

final bluetoothServiceProvider = Provider<AppBluetoothService>((ref) {
  return AppBluetoothService();
});

class BluetoothStateNotifier extends StateNotifier<AsyncValue<List<ScanResult>>> {
  final AppBluetoothService _service;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  BluetoothStateNotifier(this._service) : super(const AsyncValue.data([]));

  void startScan() {
    state = const AsyncValue.loading();
    _scanSubscription?.cancel();
    
    _scanSubscription = _service.startScan().listen(
      (results) {
        state = AsyncValue.data(results);
      },
      onError: (error, stack) {
        state = AsyncValue.error(error, stack);
      }
    );
  }

  void stopScan() {
    _service.stopScan();
    _scanSubscription?.cancel();
    // Keep the current list of devices but remove the loading state if any
    state = AsyncValue.data(state.value ?? []);
  }

  Future<bool> connect(String remoteIdStr) async {
    stopScan();
    final success = await _service.connect(remoteIdStr);
    // trigger state update to reflect new connection status in the UI if needed
    state = AsyncValue.data(state.value ?? []);
    return success;
  }

  void disconnect() {
    _service.disconnect();
    state = AsyncValue.data(state.value ?? []); 
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}

final bluetoothProvider = StateNotifierProvider<BluetoothStateNotifier, AsyncValue<List<ScanResult>>>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return BluetoothStateNotifier(service);
});
