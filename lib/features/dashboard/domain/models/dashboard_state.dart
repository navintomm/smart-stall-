import '../../../../shared/models/robot_status.dart';

class DashboardState {
  final RobotStatus? status;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.status,
    this.isLoading = false,
    this.error,
  });
}

