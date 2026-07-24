import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final bool isSimulationMode;
  
  const AppConfig({this.isSimulationMode = true});
}

class AppConfigNotifier extends StateNotifier<AppConfig> {
  AppConfigNotifier() : super(const AppConfig());

  void toggleSimulationMode() {
    state = AppConfig(isSimulationMode: !state.isSimulationMode);
  }
}

final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfig>((ref) {
  return AppConfigNotifier();
});
