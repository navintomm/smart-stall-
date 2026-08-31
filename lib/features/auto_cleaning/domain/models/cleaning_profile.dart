import '../../../../features/vision/domain/models/dirt_severity.dart';

class CleaningProfile {
  final DirtSeverity severity;
  final int waterVolumeMl;
  final int pumpDurationMs;
  final int brushDurationMs;
  final String routineId;

  const CleaningProfile({
    required this.severity,
    required this.waterVolumeMl,
    required this.pumpDurationMs,
    required this.brushDurationMs,
    required this.routineId,
  });

  factory CleaningProfile.safeDefault() {
    return const CleaningProfile(
      severity: DirtSeverity.clean,
      waterVolumeMl: 0,
      pumpDurationMs: 0,
      brushDurationMs: 0,
      routineId: 'default',
    );
  }
}
