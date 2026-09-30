import 'package:flutter/material.dart';
import '../../domain/models/dmp_trajectory_sample.dart';
import '../../domain/models/scara_geometry.dart';
import '../../domain/services/scara_kinematics.dart';

/// [ScarcaPainter] renders the 2-DOF SCARA arm for the current playback frame.
///
/// It draws:
///   - Workspace boundary ring
///   - Base circle
///   - Two arm links (link1 and link2)
///   - Three joint circles (base, elbow, end-effector)
///   - Optional end-effector trail
class ScaraPainter extends CustomPainter {
  final DmpTrajectorySample currentSample;
  final List<Offset> trailPoints;
  final bool showTrail;
  final Color armColor;
  final bool showWorkspaceBoundary;

  ScaraPainter({
    required this.currentSample,
    required this.trailPoints,
    required this.showTrail,
    required this.armColor,
    this.showWorkspaceBoundary = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final positions = ScaraKinematics.solve(
      servo1Deg: currentSample.servo1Angle,
      servo2Deg: currentSample.servo2Angle,
      origin: origin,
    );

    _drawWorkspaceBoundary(canvas, origin);
    if (showTrail) _drawTrail(canvas, trailPoints);
    _drawLink(canvas, positions.base, positions.elbow, armColor);
    _drawLink(canvas, positions.elbow, positions.endEffector, armColor.withOpacity(0.85));
    _drawJoint(canvas, positions.base, ScaraGeometry.baseRadius, armColor);
    _drawJoint(canvas, positions.elbow, ScaraGeometry.jointRadius, armColor);
    _drawEndEffector(canvas, positions.endEffector);
  }

  void _drawWorkspaceBoundary(Canvas canvas, Offset origin) {
    if (!showWorkspaceBoundary) return;
    final paint = Paint()
      ..color = const Color(0xFF7C6CE5).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(origin, ScaraGeometry.workspaceRadius, paint);
    final borderPaint = Paint()
      ..color = const Color(0xFF7C6CE5).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(origin, ScaraGeometry.workspaceRadius, borderPaint);

    // Inner dead-zone (link1 - link2 min reach)
    final innerR = (ScaraGeometry.link1Length - ScaraGeometry.link2Length).abs();
    if (innerR > 1) {
      final innerPaint = Paint()
        ..color = const Color(0xFFF7F7FB)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(origin, innerR, innerPaint);
    }
  }

  void _drawTrail(Canvas canvas, List<Offset> pts) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final paint = Paint()
      ..color = const Color(0xFF7C6CE5).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);

    // Fade-out circle at trail head
    if (pts.isNotEmpty) {
      final headPaint = Paint()
        ..color = const Color(0xFF7C6CE5).withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pts.last, 3.0, headPaint);
    }
  }

  void _drawLink(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, paint);
  }

  void _drawJoint(Canvas canvas, Offset centre, double radius, Color color) {
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centre, radius, bgPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(centre, radius, borderPaint);
  }

  void _drawEndEffector(Canvas canvas, Offset pos) {
    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF7C6CE5).withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(pos, ScaraGeometry.endEffectorRadius + 4, glowPaint);

    // Body
    final fillPaint = Paint()
      ..color = const Color(0xFF7C6CE5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, ScaraGeometry.endEffectorRadius, fillPaint);

    // White centre dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 2.0, dotPaint);
  }

  @override
  bool shouldRepaint(ScaraPainter oldDelegate) {
    return oldDelegate.currentSample != currentSample ||
        oldDelegate.trailPoints.length != trailPoints.length ||
        oldDelegate.showTrail != showTrail ||
        oldDelegate.armColor != armColor;
  }
}

/// Dual-overlay painter for COMPARE mode: draws both original and DMP arm.
class ScaraComparePainter extends CustomPainter {
  final DmpTrajectorySample originalSample;
  final DmpTrajectorySample dmpSample;
  final List<Offset> originalTrail;
  final List<Offset> dmpTrail;
  final bool showTrail;

  static const Color originalColor = Color(0xFF3B82F6); // blue
  static const Color dmpColor = Color(0xFF7C6CE5);      // violet

  ScaraComparePainter({
    required this.originalSample,
    required this.dmpSample,
    required this.originalTrail,
    required this.dmpTrail,
    required this.showTrail,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);

    _drawWorkspaceBoundary(canvas, origin);

    // Draw original arm (semi-transparent blue)
    final origPositions = ScaraKinematics.solve(
      servo1Deg: originalSample.servo1Angle,
      servo2Deg: originalSample.servo2Angle,
      origin: origin,
    );
    if (showTrail) _drawSimpleTrail(canvas, originalTrail, originalColor);
    _drawArm(canvas, origPositions, originalColor.withOpacity(0.5));

    // Draw DMP arm (violet, full opacity)
    final dmpPositions = ScaraKinematics.solve(
      servo1Deg: dmpSample.servo1Angle,
      servo2Deg: dmpSample.servo2Angle,
      origin: origin,
    );
    if (showTrail) _drawSimpleTrail(canvas, dmpTrail, dmpColor);
    _drawArm(canvas, dmpPositions, dmpColor);
  }

  void _drawWorkspaceBoundary(Canvas canvas, Offset origin) {
    final paint = Paint()
      ..color = const Color(0xFF7C6CE5).withOpacity(0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(origin, ScaraGeometry.workspaceRadius, paint);
    final borderPaint = Paint()
      ..color = const Color(0xFF7C6CE5).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(origin, ScaraGeometry.workspaceRadius, borderPaint);
  }

  void _drawSimpleTrail(Canvas canvas, List<Offset> pts, Color color) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) { path.lineTo(p.dx, p.dy); }

    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  void _drawArm(Canvas canvas, ScaraJointPositions pos, Color color) {
    final linkPaint = Paint()
      ..color = color
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pos.base, pos.elbow, linkPaint);
    canvas.drawLine(pos.elbow, pos.endEffector, linkPaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos.elbow, ScaraGeometry.jointRadius - 1, dotPaint);
    canvas.drawCircle(pos.endEffector, ScaraGeometry.endEffectorRadius, dotPaint);
  }

  @override
  bool shouldRepaint(ScaraComparePainter oldDelegate) => true;
}
