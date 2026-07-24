import 'dart:async';
import '../../features/manual_control/domain/models/command_log_entry.dart';
import '../../shared/models/robot_status.dart';
import 'package:flutter/material.dart';

class RobotSimulator {
  final _statusController = StreamController<RobotStatus>.broadcast();
  final _logController = StreamController<CommandLogEntry>.broadcast();

  RobotStatus _currentStatus = const RobotStatus(id: 'AlphaBot-01', state: 'ACTIVE', batteryLevel: 87);
  Timer? _statusTimer;

  RobotSimulator() {
    _startSimulation();
  }

  Stream<RobotStatus> get statusStream => _statusController.stream;
  Stream<CommandLogEntry> get logStream => _logController.stream;

  RobotStatus get currentStatus => _currentStatus;

  void _startSimulation() {
    _statusTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_currentStatus.batteryLevel > 5) {
        _currentStatus = RobotStatus(
          id: _currentStatus.id,
          state: _currentStatus.state,
          batteryLevel: _currentStatus.batteryLevel - 1,
        );
        _statusController.add(_currentStatus);
      }
    });
  }

  Future<void> sendCommand(String command, Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logController.add(CommandLogEntry(
      timestamp: TimeOfDay.now().format(_DummyContext()),
      command: command,
      source: 'Operator',
      status: 'Success',
      icon: Icons.check_circle_outline,
      statusColor: Colors.green,
    ));
  }

  void dispose() {
    _statusTimer?.cancel();
    _statusController.close();
    _logController.close();
  }
}

class _DummyContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
