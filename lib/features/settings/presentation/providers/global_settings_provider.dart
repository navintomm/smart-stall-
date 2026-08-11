import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettingsState {
  final double defaultMarkerSizeMeters;

  const GlobalSettingsState({
    required this.defaultMarkerSizeMeters,
  });

  GlobalSettingsState copyWith({
    double? defaultMarkerSizeMeters,
  }) {
    return GlobalSettingsState(
      defaultMarkerSizeMeters: defaultMarkerSizeMeters ?? this.defaultMarkerSizeMeters,
    );
  }
}

final globalSettingsProvider =
    StateNotifierProvider<GlobalSettingsNotifier, GlobalSettingsState>((ref) {
  return GlobalSettingsNotifier();
});

class GlobalSettingsNotifier extends StateNotifier<GlobalSettingsState> {
  static const _markerSizeKey = 'global_marker_size_m';

  GlobalSettingsNotifier()
      : super(const GlobalSettingsState(defaultMarkerSizeMeters: 0.150)) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble(_markerSizeKey);
    if (size != null) {
      state = state.copyWith(defaultMarkerSizeMeters: size);
    }
  }

  Future<void> setDefaultMarkerSize(double sizeInMeters) async {
    state = state.copyWith(defaultMarkerSizeMeters: sizeInMeters);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_markerSizeKey, sizeInMeters);
  }
}
