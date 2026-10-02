import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as classic;
import '../../domain/services/bluetooth_service.dart';
import '../../domain/services/bluetooth_classic_service.dart';

// ── Service Providers ────────────────────────────────────────────────────────

final bluetoothServiceProvider = Provider<AppBluetoothService>((ref) {
  return AppBluetoothService();
});

final bluetoothClassicServiceProvider = Provider<BluetoothClassicService>((ref) {
  return BluetoothClassicService();
});

// ── Connection Type ─────────────────────────────────────────────────────────

enum ConnectionType { none, ble, classic }

// ── Unified Connection State ────────────────────────────────────────────────

class UnifiedBluetoothState {
  final ConnectionType activeType;
  final bool isConnected;
  final String? connectedDeviceName;
  final List<ScanResult> bleResults;
  final List<classic.BluetoothDevice> classicDevices;
  final bool isScanning;
  final String? error;

  const UnifiedBluetoothState({
    this.activeType = ConnectionType.none,
    this.isConnected = false,
    this.connectedDeviceName,
    this.bleResults = const [],
    this.classicDevices = const [],
    this.isScanning = false,
    this.error,
  });

  UnifiedBluetoothState copyWith({
    ConnectionType? activeType,
    bool? isConnected,
    String? connectedDeviceName,
    List<ScanResult>? bleResults,
    List<classic.BluetoothDevice>? classicDevices,
    bool? isScanning,
    String? error,
  }) {
    return UnifiedBluetoothState(
      activeType: activeType ?? this.activeType,
      isConnected: isConnected ?? this.isConnected,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
      bleResults: bleResults ?? this.bleResults,
      classicDevices: classicDevices ?? this.classicDevices,
      isScanning: isScanning ?? this.isScanning,
      error: error,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────

class BluetoothStateNotifier extends StateNotifier<UnifiedBluetoothState> {
  final AppBluetoothService _bleService;
  final BluetoothClassicService _classicService;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  BluetoothStateNotifier(this._bleService, this._classicService)
      : super(const UnifiedBluetoothState());

  // ── BLE Scanning ──────────────────────────────────────────────────────────

  void startBleScan() {
    state = state.copyWith(isScanning: true, bleResults: [], error: null);
    _scanSubscription?.cancel();
    _scanSubscription = _bleService.startScan().listen(
      (results) {
        state = state.copyWith(bleResults: results);
      },
      onError: (error, stack) {
        state = state.copyWith(error: error.toString(), isScanning: false);
      },
    );

    // Auto-stop after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (state.isScanning) {
        state = state.copyWith(isScanning: false);
      }
    });
  }

  void stopBleScan() {
    _bleService.stopScan();
    _scanSubscription?.cancel();
    state = state.copyWith(isScanning: false);
  }

  // ── Classic Paired Devices ────────────────────────────────────────────────

  Future<void> loadPairedDevices() async {
    final devices = await _classicService.getPairedDevices();
    state = state.copyWith(classicDevices: devices);
  }

  // ── BLE Connect ───────────────────────────────────────────────────────────

  Future<bool> connectBle(String remoteIdStr, {String? name}) async {
    stopBleScan();
    final success = await _bleService.connect(remoteIdStr);
    if (success) {
      state = state.copyWith(
        activeType: ConnectionType.ble,
        isConnected: true,
        connectedDeviceName: name ?? remoteIdStr,
      );
    }
    return success;
  }

  // ── Classic Connect ───────────────────────────────────────────────────────

  Future<bool> connectClassic(String address, {String? name}) async {
    final success = await _classicService.connect(address);
    if (success) {
      state = state.copyWith(
        activeType: ConnectionType.classic,
        isConnected: true,
        connectedDeviceName: name ?? address,
      );
    }
    return success;
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  void disconnect() {
    if (state.activeType == ConnectionType.ble) {
      _bleService.disconnect();
    } else if (state.activeType == ConnectionType.classic) {
      _classicService.disconnect();
    }
    state = state.copyWith(
      activeType: ConnectionType.none,
      isConnected: false,
      connectedDeviceName: null,
    );
  }

  // ── Unified Send ──────────────────────────────────────────────────────────

  Future<void> sendCommand(String command) async {
    if (state.activeType == ConnectionType.ble) {
      await _bleService.sendCommand(command);
    } else if (state.activeType == ConnectionType.classic) {
      await _classicService.sendCommand(command);
    }
  }

  // ── Unified Incoming Data ─────────────────────────────────────────────────

  Stream<String> get incomingData {
    if (state.activeType == ConnectionType.classic) {
      return _classicService.incomingData;
    }
    return _bleService.incomingData;
  }

  /// Get the active service's incoming data stream regardless of type.
  /// Both BLE and Classic streams are merged.
  Stream<String> get mergedIncomingData {
    return _bleService.incomingData.asBroadcastStream().handleError((_) {});
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}

// ── Provider ────────────────────────────────────────────────────────────────

final bluetoothProvider =
    StateNotifierProvider<BluetoothStateNotifier, UnifiedBluetoothState>((ref) {
  final bleService = ref.watch(bluetoothServiceProvider);
  final classicService = ref.watch(bluetoothClassicServiceProvider);
  return BluetoothStateNotifier(bleService, classicService);
});
