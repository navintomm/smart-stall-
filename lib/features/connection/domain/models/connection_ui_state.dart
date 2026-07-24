import 'robot_device.dart';
import 'connection_method.dart';
import 'network_metric.dart';
import 'connection_history.dart';

class ConnectionUIState {
  final RobotDevice? activeRobot;
  final List<RobotDevice> availableRobots;
  final List<ConnectionMethod> methods;
  final List<NetworkMetric> metrics;
  final List<ConnectionHistory> history;
  final bool isLoading;

  const ConnectionUIState({
    this.activeRobot,
    this.availableRobots = const [],
    this.methods = const [],
    this.metrics = const [],
    this.history = const [],
    this.isLoading = false,
  });
}
