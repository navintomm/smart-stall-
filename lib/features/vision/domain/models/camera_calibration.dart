import 'dart:convert';

/// Simplified camera calibration using focal-length estimation from a known
/// ArUco marker at a known distance.  This replaces the previous checkerboard
/// calibration which was impractical for field operators.
class CameraCalibration {
  /// Estimated focal length in pixels (fx = fy assumed equal for phone cameras).
  final double focalLengthPx;

  /// The pixel width of the marker when calibration was performed.
  final double markerPixelWidth;

  /// The known real-world distance (metres) at which the marker was placed
  /// during calibration.
  final double calibrationDistanceM;

  /// Physical marker size in metres used during calibration.
  final double markerSizeM;

  /// Frame dimensions at calibration time.
  final int imageWidth;
  final int imageHeight;

  /// Whether this calibration contains valid data.
  final bool isValid;

  /// ISO-8601 timestamp of when calibration was performed.
  final String timestamp;

  CameraCalibration({
    required this.focalLengthPx,
    required this.markerPixelWidth,
    required this.calibrationDistanceM,
    required this.markerSizeM,
    required this.imageWidth,
    required this.imageHeight,
    required this.isValid,
    required this.timestamp,
  });

  /// An empty / uncalibrated instance.
  factory CameraCalibration.empty() {
    return CameraCalibration(
      focalLengthPx: 0.0,
      markerPixelWidth: 0.0,
      calibrationDistanceM: 0.0,
      markerSizeM: 0.0,
      imageWidth: 0,
      imageHeight: 0,
      isValid: false,
      timestamp: '',
    );
  }

  /// Build the 3×3 camera intrinsic matrix expected by [ArucoPoseService].
  ///
  /// ```
  /// [ fx   0   cx ]
  /// [  0  fy   cy ]
  /// [  0   0    1 ]
  /// ```
  List<List<double>> get cameraMatrix {
    final cx = imageWidth / 2.0;
    final cy = imageHeight / 2.0;
    return [
      [focalLengthPx, 0.0, cx],
      [0.0, focalLengthPx, cy],
      [0.0, 0.0, 1.0],
    ];
  }

  /// Zero distortion coefficients (good enough for most phone lenses).
  List<double> get distCoeffs => [0.0, 0.0, 0.0, 0.0, 0.0];

  /// Reprojection error is not applicable for focal-length calibration.
  double get reprojectionError => 0.0;

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'focalLengthPx': focalLengthPx,
        'markerPixelWidth': markerPixelWidth,
        'calibrationDistanceM': calibrationDistanceM,
        'markerSizeM': markerSizeM,
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
        'isValid': isValid,
        'timestamp': timestamp,
      };

  factory CameraCalibration.fromMap(Map<String, dynamic> map) {
    return CameraCalibration(
      focalLengthPx: (map['focalLengthPx'] as num).toDouble(),
      markerPixelWidth: (map['markerPixelWidth'] as num).toDouble(),
      calibrationDistanceM: (map['calibrationDistanceM'] as num).toDouble(),
      markerSizeM: (map['markerSizeM'] as num).toDouble(),
      imageWidth: map['imageWidth'] as int,
      imageHeight: map['imageHeight'] as int,
      isValid: map['isValid'] as bool,
      timestamp: map['timestamp'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CameraCalibration.fromJson(String source) =>
      CameraCalibration.fromMap(json.decode(source) as Map<String, dynamic>);
}
