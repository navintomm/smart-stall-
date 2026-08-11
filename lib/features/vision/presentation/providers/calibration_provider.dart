import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/camera_calibration.dart';

final calibrationProvider =
    StateNotifierProvider<CalibrationNotifier, CameraCalibration>((ref) {
  return CalibrationNotifier();
});

class CalibrationNotifier extends StateNotifier<CameraCalibration> {
  static const _prefsKey = 'camera_calibration_v2';

  CalibrationNotifier() : super(CameraCalibration.empty()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsKey);
    if (data != null) {
      try {
        state = CameraCalibration.fromJson(data);
      } catch (e) {
        debugPrint('Failed to load calibration: $e');
        // Try legacy key and clear it
        await prefs.remove('camera_calibration_data');
      }
    }
  }

  Future<void> saveCalibration(CameraCalibration calibration) async {
    state = calibration;
    if (calibration.isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, calibration.toJson());
    }
  }

  Future<void> clearCalibration() async {
    state = CameraCalibration.empty();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
