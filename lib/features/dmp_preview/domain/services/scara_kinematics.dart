import 'dart:math';
import 'dart:ui';
import '../models/scara_geometry.dart';

/// Pure forward-kinematics calculation for the 2-DOF SCARA arm.
///
/// Convention (preview coordinates):
///   - Base joint is the origin.
///   - Positive X extends to the right.
///   - Positive Y extends downward (Canvas coordinate system).
///   - servo1Angle rotates Joint 1 (base rotation), 0° = pointing right.
///   - servo2Angle rotates Joint 2 relative to Link 1, 0° = straight.
///
/// NOTE: This uses preview-parameter link lengths from [ScaraGeometry].
/// Physical calibration is NOT applied in this checkpoint.
class ScaraKinematics {
  /// Computes [joint1Position] and [endEffectorPosition] from servo angles.
  ///
  /// [servo1Deg] – angle of Joint 1 in degrees.
  /// [servo2Deg] – angle of Joint 2 relative to Link 1, in degrees.
  /// [origin]    – canvas position of the base joint.
  ///
  /// Returns ({Offset joint1, Offset joint2}) where joint1 == origin,
  /// joint2 == elbow, and the end-effector is the return value.
  static ScaraJointPositions solve({
    required double servo1Deg,
    required double servo2Deg,
    required Offset origin,
  }) {
    final theta1 = _deg2rad(servo1Deg);
    final theta2 = _deg2rad(servo2Deg);

    final joint1 = origin; // base joint is fixed at origin

    // Elbow position (end of Link 1)
    final elbow = Offset(
      origin.dx + ScaraGeometry.link1Length * cos(theta1),
      origin.dy + ScaraGeometry.link1Length * sin(theta1),
    );

    // End-effector position (end of Link 2)
    final endEffector = Offset(
      elbow.dx + ScaraGeometry.link2Length * cos(theta1 + theta2),
      elbow.dy + ScaraGeometry.link2Length * sin(theta1 + theta2),
    );

    return ScaraJointPositions(
      base: joint1,
      elbow: elbow,
      endEffector: endEffector,
    );
  }

  static double _deg2rad(double degrees) => degrees * pi / 180.0;
}

/// The three key Cartesian positions of the SCARA arm.
class ScaraJointPositions {
  final Offset base;
  final Offset elbow;
  final Offset endEffector;

  const ScaraJointPositions({
    required this.base,
    required this.elbow,
    required this.endEffector,
  });
}
