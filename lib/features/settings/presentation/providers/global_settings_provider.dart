import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettingsState {
  final double defaultMarkerSizeMeters;
  final bool debugVisionMode;

  const GlobalSettingsState({
    required this.defaultMarkerSizeMeters,
    this.debugVisionMode = false,
  });

  GlobalSettingsState copyWith({
    double? defaultMarkerSizeMeters,
    bool? debugVisionMode,
  }) {
    return GlobalSettingsState(
      defaultMarkerSizeMeters: defaultMarkerSizeMeters ?? this.defaultMarkerSizeMeters,
      debugVisionMode: debugVisionMode ?? this.debugVisionMode,
    );
  }
}

final globalSettingsProvider =
    StateNotifierProvider<GlobalSettingsNotifier, GlobalSettingsState>((ref) {
  return GlobalSettingsNotifier();
});

class GlobalSettingsNotifier extends StateNotifier<GlobalSettingsState> {
  static const _markerSizeKey = 'global_marker_size_m';
  static const _debugVisionKey = 'global_debug_vision';

  GlobalSettingsNotifier()
      : super(const GlobalSettingsState(defaultMarkerSizeMeters: 0.150)) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble(_markerSizeKey);
    final debug = prefs.getBool(_debugVisionKey);
    
    state = state.copyWith(
      defaultMarkerSizeMeters: size ?? state.defaultMarkerSizeMeters,
      debugVisionMode: debug ?? state.debugVisionMode,
    );
  }

  Future<void> setDefaultMarkerSize(double sizeInMeters) async {
    state = state.copyWith(defaultMarkerSizeMeters: sizeInMeters);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_markerSizeKey, sizeInMeters);
  }

  Future<void> setDebugVisionMode(bool enabled) async {
    state = state.copyWith(debugVisionMode: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_debugVisionKey, enabled);
  }
}
