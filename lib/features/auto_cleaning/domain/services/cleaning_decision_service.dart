import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/vision/domain/models/dirt_detection_result.dart';
import '../../../../features/vision/domain/models/dirt_severity.dart';
import '../models/cleaning_profile.dart';

final cleaningDecisionServiceProvider = Provider<CleaningDecisionService>((ref) {
  return CleaningDecisionService();
});

class CleaningDecisionService {
  // Configurable dosing parameters
  // TODO: These should ideally come from remote config or local settings
  final int _pumpFlowRateMlPerSec = 70;

  /// Converts a [DirtDetectionResult] into a [CleaningProfile] recommendation.
  CleaningProfile generateRecommendation(DirtDetectionResult result) {
    if (!result.detected) {
      return CleaningProfile.safeDefault();
    }

    int waterVolumeMl = 0;
    int brushDurationMs = 0;
    String routineId = 'standard';

    switch (result.severity) {
      case DirtSeverity.clean:
        waterVolumeMl = 50;
        brushDurationMs = 2000;
        routineId = 'quick_rinse';
        break;
      case DirtSeverity.light:
        waterVolumeMl = 150;
        brushDurationMs = 5000;
        routineId = 'light_clean';
        break;
      case DirtSeverity.moderate:
        waterVolumeMl = 300;
        brushDurationMs = 10000;
        routineId = 'standard_clean';
        break;
      case DirtSeverity.heavy:
        waterVolumeMl = 500;
        brushDurationMs = 15000;
        routineId = 'heavy_clean';
        break;
      case DirtSeverity.severe:
        waterVolumeMl = 800; // Assuming this is max permitted
        brushDurationMs = 25000;
        routineId = 'intensive_clean';
        break;
    }

    // Calculate pump duration based on required volume and flow rate
    // Required water = 350 mL -> flow rate 70 mL/s -> duration = 5 seconds
    double durationSec = waterVolumeMl / _pumpFlowRateMlPerSec;
    int pumpDurationMs = (durationSec * 1000).toInt();

    return CleaningProfile(
      severity: result.severity,
      waterVolumeMl: waterVolumeMl,
      pumpDurationMs: pumpDurationMs,
      brushDurationMs: brushDurationMs,
      routineId: routineId,
    );
  }
}
