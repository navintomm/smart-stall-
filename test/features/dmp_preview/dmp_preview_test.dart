import 'package:flutter_test/flutter_test.dart';

import 'package:smartstall_operator/features/dmp_preview/domain/models/dmp_joint_metrics.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/models/dmp_result.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/models/dmp_trajectory_sample.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/models/scara_geometry.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/services/dmp_validator.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/services/scara_kinematics.dart';


// ─── Helpers ───────────────────────────────────────────────────────────────────

DmpTrajectorySample _sample(double t, double s1, double s2) =>
    DmpTrajectorySample(timeSeconds: t, servo1Angle: s1, servo2Angle: s2);

DmpJointMetrics _metrics(String name) => DmpJointMetrics(
      jointName: name,
      mae: 1.0,
      rmse: 1.2,
      maxError: 2.0,
      smoothnessOriginal: 10.0,
      smoothnessGenerated: 0.5,
    );

DmpResult _validResult({
  bool startPreserved = true,
  bool goalPreserved = true,
  bool noNan = true,
  bool noInf = true,
  int sampleCount = 50,
}) {
  final samples = List.generate(
    sampleCount,
    (i) => _sample(i * 0.1, i.toDouble(), i * 0.5),
  );
  return DmpResult(
    routineId: 'test_id',
    routineName: 'Test Routine',
    durationSeconds: sampleCount * 0.1,
    originalSamples: samples,
    generatedSamples: samples,
    servo1Metrics: _metrics('servo1_angle'),
    servo2Metrics: _metrics('servo2_angle'),
    startPositionPreserved: startPreserved,
    goalPositionPreserved: goalPreserved,
    noNanValues: noNan,
    noInfiniteValues: noInf,
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  // 1. DmpResult model
  group('DmpResult', () {
    test('hasSufficientSamples returns true when >= 10 samples', () {
      expect(_validResult(sampleCount: 10).hasSufficientSamples, isTrue);
      expect(_validResult(sampleCount: 100).hasSufficientSamples, isTrue);
    });

    test('hasSufficientSamples returns false when < 10 samples', () {
      expect(_validResult(sampleCount: 9).hasSufficientSamples, isFalse);
    });

    test('sampleCount matches generated samples length', () {
      final r = _validResult(sampleCount: 25);
      expect(r.sampleCount, 25);
    });

    test('copyWith preserves all fields except isApproved', () {
      final r = _validResult();
      final approved = r.copyWith(isApproved: true);
      expect(approved.isApproved, isTrue);
      expect(approved.routineId, r.routineId);
      expect(approved.generatedSamples.length, r.generatedSamples.length);
    });

    test('isApproved defaults to false', () {
      expect(_validResult().isApproved, isFalse);
    });
  });

  // 2. Invalid trajectory detection
  group('DmpValidator — invalid trajectories', () {
    test('FAIL when fewer than 10 samples', () {
      final r = _validResult(sampleCount: 5);
      final checks = DmpValidator.validate(r);
      final suffCheck =
          checks.firstWhere((c) => c.label == 'Sufficient Samples');
      expect(suffCheck.status, ValidationStatus.fail);
    });

    test('FAIL when NaN values present', () {
      final r = _validResult(noNan: false);
      final checks = DmpValidator.validate(r);
      final nanCheck = checks.firstWhere((c) => c.label == 'No NaN Values');
      expect(nanCheck.status, ValidationStatus.fail);
    });

    test('FAIL when infinite values present', () {
      final r = _validResult(noInf: false);
      final checks = DmpValidator.validate(r);
      final infCheck =
          checks.firstWhere((c) => c.label == 'No Infinite Values');
      expect(infCheck.status, ValidationStatus.fail);
    });

    test('REVIEW when goal position not preserved', () {
      final r = _validResult(goalPreserved: false);
      final checks = DmpValidator.validate(r);
      final goalCheck = checks.firstWhere((c) => c.label == 'Goal Position');
      expect(goalCheck.status, ValidationStatus.review);
    });

    test('REVIEW when start position not preserved', () {
      final r = _validResult(startPreserved: false);
      final checks = DmpValidator.validate(r);
      final startCheck =
          checks.firstWhere((c) => c.label == 'Start Position');
      expect(startCheck.status, ValidationStatus.review);
    });

    test('allPassed returns false when any FAIL exists', () {
      final r = _validResult(noNan: false);
      expect(DmpValidator.allPassed(DmpValidator.validate(r)), isFalse);
    });

    test('allPassed returns false when any REVIEW exists', () {
      final r = _validResult(goalPreserved: false);
      expect(DmpValidator.allPassed(DmpValidator.validate(r)), isFalse);
    });

    test('allPassed returns true for a valid result', () {
      final r = _validResult();
      expect(DmpValidator.allPassed(DmpValidator.validate(r)), isTrue);
    });
  });

  // 3. Kinematics calculations
  group('ScaraKinematics', () {
    const origin = Offset(100, 100);

    test('base joint is always at origin', () {
      final pos = ScaraKinematics.solve(
          servo1Deg: 0, servo2Deg: 0, origin: origin);
      expect(pos.base, origin);
    });

    test('servo1=0, servo2=0 — arm extends fully to the right', () {
      final pos = ScaraKinematics.solve(
          servo1Deg: 0, servo2Deg: 0, origin: origin);
      // Link 1 points right: elbow at (origin.dx + L1, origin.dy)
      expect(pos.elbow.dx,
          closeTo(origin.dx + ScaraGeometry.link1Length, 0.001));
      expect(pos.elbow.dy, closeTo(origin.dy, 0.001));
      // Link 2 also points right: end-effector further right
      expect(pos.endEffector.dx,
          closeTo(
              origin.dx + ScaraGeometry.link1Length + ScaraGeometry.link2Length,
              0.001));
    });

    test('servo1=90° — elbow moves straight down (Canvas Y-down)', () {
      final pos = ScaraKinematics.solve(
          servo1Deg: 90, servo2Deg: 0, origin: origin);
      expect(pos.elbow.dx, closeTo(origin.dx, 0.001));
      expect(pos.elbow.dy,
          closeTo(origin.dy + ScaraGeometry.link1Length, 0.001));
    });

    test('servo1=-90° — elbow moves straight up', () {
      final pos = ScaraKinematics.solve(
          servo1Deg: -90, servo2Deg: 0, origin: origin);
      expect(pos.elbow.dx, closeTo(origin.dx, 0.001));
      expect(pos.elbow.dy,
          closeTo(origin.dy - ScaraGeometry.link1Length, 0.001));
    });

    test('end-effector distance from base is at most workspaceRadius', () {
      for (final s1 in [-90.0, 0.0, 45.0, 90.0]) {
        for (final s2 in [-90.0, 0.0, 90.0]) {
          final pos = ScaraKinematics.solve(
              servo1Deg: s1, servo2Deg: s2, origin: origin);
          final dist = (pos.endEffector - origin).distance;
          expect(dist, lessThanOrEqualTo(ScaraGeometry.workspaceRadius + 0.01));
        }
      }
    });
  });

  // 4. Playback interpolation
  group('Playback interpolation', () {
    final samples = List.generate(
        100, (i) => _sample(i * 0.05, i.toDouble(), i * 2.0));

    test('progress=0.0 maps to index 0', () {
      final idx = (0.0 * (samples.length - 1)).round().clamp(0, samples.length - 1);
      expect(idx, 0);
    });

    test('progress=1.0 maps to last index', () {
      final idx = (1.0 * (samples.length - 1)).round().clamp(0, samples.length - 1);
      expect(idx, samples.length - 1);
    });

    test('progress=0.5 maps to middle index', () {
      final idx = (0.5 * (samples.length - 1)).round().clamp(0, samples.length - 1);
      expect(idx, closeTo(samples.length ~/ 2, 1));
    });
  });

  // 5. Validation model checks
  group('DmpValidator — valid trajectory', () {
    test('All 8 checks present for valid result', () {
      final checks = DmpValidator.validate(_validResult());
      expect(checks.length, 8);
    });

    test('All checks pass for a pristine result', () {
      final checks = DmpValidator.validate(_validResult());
      for (final c in checks) {
        expect(c.status, ValidationStatus.pass,
            reason: 'Failed: ${c.label} — ${c.detail}');
      }
    });

    test('Servo 1 Data check passes with angle range in detail', () {
      final checks = DmpValidator.validate(_validResult(sampleCount: 20));
      final s1 = checks.firstWhere((c) => c.label == 'Servo 1 Data');
      expect(s1.status, ValidationStatus.pass);
      expect(s1.detail, contains('°'));
    });
  });
}
