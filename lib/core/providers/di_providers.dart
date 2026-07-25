import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_config_provider.dart';

// Simulators
import '../simulation/robot_simulator.dart';
import '../simulation/telemetry_simulator.dart';
import '../simulation/connection_simulator.dart';
import '../simulation/diagnostics_simulator.dart';

// Transports & Protocol
import '../communication/transports/wifi_transport.dart';
import '../communication/protocol/protocol_codec.dart';


// Repository Interfaces
import '../repositories/robot_repository.dart';
import '../repositories/connection_repository.dart';
import '../repositories/telemetry_repository.dart';
import '../repositories/diagnostics_repository.dart';

// Mock Repositories
import '../repositories/mock/mock_robot_repository.dart';
import '../repositories/mock/mock_connection_repository.dart';
import '../repositories/mock/mock_telemetry_repository.dart';
import '../repositories/mock/mock_diagnostics_repository.dart';

// Hardware Repositories
import '../repositories/hardware/hardware_robot_repository.dart';
import '../repositories/hardware/hardware_connection_repository.dart';
import '../repositories/hardware/hardware_telemetry_repository.dart';
import '../repositories/hardware/hardware_diagnostics_repository.dart';

// Simulation Singletons
final robotSimulatorProvider = Provider<RobotSimulator>((ref) {
  final sim = RobotSimulator();
  ref.onDispose(() => sim.dispose());
  return sim;
});
final telemetrySimulatorProvider = Provider<TelemetrySimulator>((ref) {
  final sim = TelemetrySimulator();
  ref.onDispose(() => sim.dispose());
  return sim;
});
final connectionSimulatorProvider = Provider<ConnectionSimulator>((ref) {
  final sim = ConnectionSimulator();
  ref.onDispose(() => sim.dispose());
  return sim;
});
final diagnosticsSimulatorProvider = Provider<DiagnosticsSimulator>((ref) {
  final sim = DiagnosticsSimulator();
  ref.onDispose(() => sim.dispose());
  return sim;
});

// Transport Singletons
final activeTransportProvider = Provider((ref) => WifiTransport());
final protocolCodecProvider = Provider((ref) => ProtocolCodec());


// Smart Repositories (Switch based on Developer Mode)
final robotRepositoryProvider = Provider<RobotRepository>((ref) {
  final isSim = ref.watch(appConfigProvider).isSimulationMode;
  if (isSim) {
    return MockRobotRepository(ref.watch(robotSimulatorProvider));
  } else {
    return HardwareRobotRepository(ref.watch(activeTransportProvider), ref.watch(protocolCodecProvider));
  }
});

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  final isSim = ref.watch(appConfigProvider).isSimulationMode;
  if (isSim) {
    return MockConnectionRepository(ref.watch(connectionSimulatorProvider));
  } else {
    return HardwareConnectionRepository(ref.watch(activeTransportProvider));
  }
});

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  final isSim = ref.watch(appConfigProvider).isSimulationMode;
  if (isSim) {
    return MockTelemetryRepository(ref.watch(telemetrySimulatorProvider));
  } else {
    return HardwareTelemetryRepository(ref.watch(activeTransportProvider), ref.watch(protocolCodecProvider));
  }
});

final diagnosticsRepositoryProvider = Provider<DiagnosticsRepository>((ref) {
  final isSim = ref.watch(appConfigProvider).isSimulationMode;
  if (isSim) {
    return MockDiagnosticsRepository(ref.watch(diagnosticsSimulatorProvider));
  } else {
    return HardwareDiagnosticsRepository(ref.watch(activeTransportProvider), ref.watch(protocolCodecProvider));
  }
});

