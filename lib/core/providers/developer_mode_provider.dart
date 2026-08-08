import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the hidden Developer Mode is unlocked for this session.
/// Unlock via 7-tap on the app version label in Settings.
final developerModeProvider = StateNotifierProvider<DeveloperModeNotifier, bool>((ref) {
  return DeveloperModeNotifier();
});

class DeveloperModeNotifier extends StateNotifier<bool> {
  DeveloperModeNotifier() : super(false);

  int _tapCount = 0;

  /// Call this each time the user taps the secret version label.
  /// Returns true when the mode becomes unlocked.
  bool onVersionTap() {
    _tapCount++;
    if (_tapCount >= 7) {
      _tapCount = 0;
      state = true;
      return true;
    }
    return false;
  }

  void lock() {
    _tapCount = 0;
    state = false;
  }
}
