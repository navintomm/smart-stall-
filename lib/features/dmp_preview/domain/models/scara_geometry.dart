/// Configurable geometry constants for the 2D SCARA arm preview.
///
/// These are PREVIEW PARAMETERS only — not physically calibrated dimensions.
/// They define the visual proportions of the Canvas-drawn arm.
/// Replace with measured physical link lengths once hardware is validated.
class ScaraGeometry {
  /// Length of the first arm link (base joint → elbow), in canvas units.
  /// [PREVIEW PARAMETER — not physically calibrated]
  static const double link1Length = 80.0;

  /// Length of the second arm link (elbow → end-effector), in canvas units.
  /// [PREVIEW PARAMETER — not physically calibrated]
  static const double link2Length = 60.0;

  /// Base-joint position is drawn at the canvas centre by default.
  /// No offset needed — the painter centres itself.

  /// Radius of joint dot indicators, in canvas units.
  static const double jointRadius = 7.0;

  /// Radius of the end-effector circle, in canvas units.
  static const double endEffectorRadius = 5.0;

  /// Radius of the base anchor circle.
  static const double baseRadius = 10.0;

  /// Approximate workspace radius = link1Length + link2Length.
  /// Used to draw the workspace boundary ring.
  static double get workspaceRadius => link1Length + link2Length;
}
