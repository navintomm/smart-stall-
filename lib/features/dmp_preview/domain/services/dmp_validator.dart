import '../models/dmp_result.dart';


/// A single validation check result.
class ValidationCheck {
  final String label;
  final ValidationStatus status;
  final String detail;

  const ValidationCheck({
    required this.label,
    required this.status,
    required this.detail,
  });
}

enum ValidationStatus { pass, review, fail }

/// Pure validation logic for a [DmpResult].
///
/// Only checks that are supported by actual available data are implemented.
/// Physical servo limits are NOT invented — they are absent here and will be
/// added once physical limits are measured.
class DmpValidator {
  static List<ValidationCheck> validate(DmpResult result) {
    return [
      _checkHasSamples(result),
      _checkServo1Values(result),
      _checkServo2Values(result),
      _checkNoNaN(result),
      _checkNoInfinite(result),
      _checkDuration(result),
      _checkStartPosition(result),
      _checkGoalPosition(result),
    ];
  }

  static ValidationCheck _checkHasSamples(DmpResult r) {
    if (!r.hasSufficientSamples) {
      return const ValidationCheck(
        label: 'Sufficient Samples',
        status: ValidationStatus.fail,
        detail: 'Trajectory has fewer than 10 samples — too short to preview.',
      );
    }
    return ValidationCheck(
      label: 'Sufficient Samples',
      status: ValidationStatus.pass,
      detail: '${r.sampleCount} samples recorded.',
    );
  }

  static ValidationCheck _checkServo1Values(DmpResult r) {
    final angles = r.generatedSamples.map((s) => s.servo1Angle).toList();
    if (angles.isEmpty) {
      return const ValidationCheck(
        label: 'Servo 1 Data',
        status: ValidationStatus.fail,
        detail: 'No Servo 1 data in generated trajectory.',
      );
    }
    final min = angles.reduce((a, b) => a < b ? a : b);
    final max = angles.reduce((a, b) => a > b ? a : b);
    return ValidationCheck(
      label: 'Servo 1 Data',
      status: ValidationStatus.pass,
      detail: 'Range: ${min.toStringAsFixed(1)}° – ${max.toStringAsFixed(1)}°',
    );
  }

  static ValidationCheck _checkServo2Values(DmpResult r) {
    final angles = r.generatedSamples.map((s) => s.servo2Angle).toList();
    if (angles.isEmpty) {
      return const ValidationCheck(
        label: 'Servo 2 Data',
        status: ValidationStatus.fail,
        detail: 'No Servo 2 data in generated trajectory.',
      );
    }
    final min = angles.reduce((a, b) => a < b ? a : b);
    final max = angles.reduce((a, b) => a > b ? a : b);
    return ValidationCheck(
      label: 'Servo 2 Data',
      status: ValidationStatus.pass,
      detail: 'Range: ${min.toStringAsFixed(1)}° – ${max.toStringAsFixed(1)}°',
    );
  }

  static ValidationCheck _checkNoNaN(DmpResult r) {
    if (!r.noNanValues) {
      return const ValidationCheck(
        label: 'No NaN Values',
        status: ValidationStatus.fail,
        detail: 'Generated trajectory contains NaN values.',
      );
    }
    return const ValidationCheck(
      label: 'No NaN Values',
      status: ValidationStatus.pass,
      detail: 'All trajectory values are finite numbers.',
    );
  }

  static ValidationCheck _checkNoInfinite(DmpResult r) {
    if (!r.noInfiniteValues) {
      return const ValidationCheck(
        label: 'No Infinite Values',
        status: ValidationStatus.fail,
        detail: 'Generated trajectory contains infinite values.',
      );
    }
    return const ValidationCheck(
      label: 'No Infinite Values',
      status: ValidationStatus.pass,
      detail: 'No overflow in generated trajectory.',
    );
  }

  static ValidationCheck _checkDuration(DmpResult r) {
    if (r.durationSeconds <= 0) {
      return const ValidationCheck(
        label: 'Valid Duration',
        status: ValidationStatus.fail,
        detail: 'Duration is zero or negative.',
      );
    }
    return ValidationCheck(
      label: 'Valid Duration',
      status: ValidationStatus.pass,
      detail: '${r.durationSeconds.toStringAsFixed(2)} s',
    );
  }

  static ValidationCheck _checkStartPosition(DmpResult r) {
    if (!r.startPositionPreserved) {
      return const ValidationCheck(
        label: 'Start Position',
        status: ValidationStatus.review,
        detail: 'Start position deviation > 0.1°. Verify before executing.',
      );
    }
    return const ValidationCheck(
      label: 'Start Position',
      status: ValidationStatus.pass,
      detail: 'Start position preserved within 0.1°.',
    );
  }

  static ValidationCheck _checkGoalPosition(DmpResult r) {
    if (!r.goalPositionPreserved) {
      return const ValidationCheck(
        label: 'Goal Position',
        status: ValidationStatus.review,
        detail: 'Goal position deviation > 1.5°. Trajectory may not fully reach target.',
      );
    }
    return const ValidationCheck(
      label: 'Goal Position',
      status: ValidationStatus.pass,
      detail: 'Goal position preserved within 1.5°.',
    );
  }

  /// Summary: returns true if all checks are PASS (no FAIL or REVIEW).
  static bool allPassed(List<ValidationCheck> checks) =>
      checks.every((c) => c.status == ValidationStatus.pass);
}
