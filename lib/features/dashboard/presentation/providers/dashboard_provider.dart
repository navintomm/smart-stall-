import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_state.dart';
import '../../../../core/providers/di_providers.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final simulator = ref.watch(robotSimulatorProvider);
  final notifier = DashboardNotifier(simulator.currentStatus);
  
  ref.listen(robotSimulatorProvider.select((s) => s.statusStream), (_, stream) {
    stream.listen((newStatus) {
      notifier.updateStatus(newStatus);
    });
  });
  
  return notifier;
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(status) : super(DashboardState(status: status));

  void updateStatus(status) {
    state = DashboardState(status: status, isLoading: false);
  }

  void refresh() {
    state = DashboardState(status: state.status, isLoading: false);
  }
}
