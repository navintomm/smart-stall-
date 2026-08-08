enum AlignmentStatus {
  scanning, // Looking for marker
  aligning, // Marker found, but outside tolerances
  ready, // Marker found and within tolerances
  markerLost, // Marker was lost
  error, // Camera or calibration error
}

class AlignmentResult {
  final double horizontalErrorM;
  final double verticalErrorM;
  final double distanceErrorM;
  final double yawErrorDeg;
  
  /// 0.0 to 1.0 (1.0 means perfectly aligned within tolerances)
  final double score;
  final AlignmentStatus status;

  AlignmentResult({
    required this.horizontalErrorM,
    required this.verticalErrorM,
    required this.distanceErrorM,
    required this.yawErrorDeg,
    required this.score,
    required this.status,
  });

  factory AlignmentResult.empty(AlignmentStatus status) {
    return AlignmentResult(
      horizontalErrorM: 0.0,
      verticalErrorM: 0.0,
      distanceErrorM: 0.0,
      yawErrorDeg: 0.0,
      score: 0.0,
      status: status,
    );
  }
}
