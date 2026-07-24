import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/connection_ui_state.dart';
import '../../domain/models/robot_device.dart';
import '../../domain/models/connection_method.dart';
import '../../domain/models/network_metric.dart';
import '../../domain/models/connection_history.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/repositories/connection_repository.dart';

final connectionProvider = StateNotifierProvider<ConnectionNotifier, ConnectionUIState>((ref) {
    final repo = ref.watch(connectionRepositoryProvider);
  
  final notifier = ConnectionNotifier(repo);

  ref.listen(diagnosticsSimulatorProvider.select((s) => s.networkMetricsStream), (_, stream) {
    stream.listen((newMetricsMap) {
      notifier.updateMetrics(newMetricsMap);
    });
  });

  ref.listen(connectionRepositoryProvider.select((r) => r.connectionStateStream), (_, stream) {
    stream.listen((stateStr) {
      notifier.updateConnectionState(stateStr);
    });
  });

  return notifier;
});

class ConnectionNotifier extends StateNotifier<ConnectionUIState> {
  final ConnectionRepository repo;

  ConnectionNotifier(this.repo) : super(
    ConnectionUIState(
      activeRobot: RobotDevice.placeholders.first,
      availableRobots: RobotDevice.placeholders,
      methods: ConnectionMethod.placeholders,
      metrics: NetworkMetric.placeholders,
      history: ConnectionHistory.placeholders,
    )
  );

  void updateMetrics(Map<String, String> metricsMap) {
    final updatedMetrics = metricsMap.entries.map((e) => NetworkMetric(name: e.key, value: e.value)).toList();
    state = ConnectionUIState(
      activeRobot: state.activeRobot,
      availableRobots: state.availableRobots,
      methods: state.methods,
      metrics: updatedMetrics,
      history: state.history,
    );
  }

  void updateConnectionState(String statusStr) {
    if (state.activeRobot != null) {
      final updatedRobot = RobotDevice(
        id: state.activeRobot!.id,
        name: state.activeRobot!.name,
        status: statusStr,
        type: state.activeRobot!.type,
        signalQuality: state.activeRobot!.signalQuality,
        isFavorite: state.activeRobot!.isFavorite,
      );
      state = ConnectionUIState(
        activeRobot: updatedRobot,
        availableRobots: state.availableRobots,
        methods: state.methods,
        metrics: state.metrics,
        history: state.history,
      );
    }
  }

  void refresh() {
  }
}

