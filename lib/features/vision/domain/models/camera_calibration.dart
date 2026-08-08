import 'dart:convert';

class CameraCalibration {
  final List<List<double>> cameraMatrix;
  final List<double> distCoeffs;
  final double reprojectionError;
  final int imageWidth;
  final int imageHeight;
  final bool isValid;

  CameraCalibration({
    required this.cameraMatrix,
    required this.distCoeffs,
    required this.reprojectionError,
    required this.imageWidth,
    required this.imageHeight,
    required this.isValid,
  });

  factory CameraCalibration.empty() {
    return CameraCalibration(
      cameraMatrix: [
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
      ],
      distCoeffs: [0.0, 0.0, 0.0, 0.0, 0.0],
      reprojectionError: 0.0,
      imageWidth: 0,
      imageHeight: 0,
      isValid: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cameraMatrix': cameraMatrix,
      'distCoeffs': distCoeffs,
      'reprojectionError': reprojectionError,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'isValid': isValid,
    };
  }

  factory CameraCalibration.fromMap(Map<String, dynamic> map) {
    return CameraCalibration(
      cameraMatrix: (map['cameraMatrix'] as List)
          .map((row) => (row as List).map((e) => e as double).toList())
          .toList(),
      distCoeffs: (map['distCoeffs'] as List).map((e) => e as double).toList(),
      reprojectionError: map['reprojectionError'] as double,
      imageWidth: map['imageWidth'] as int,
      imageHeight: map['imageHeight'] as int,
      isValid: map['isValid'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory CameraCalibration.fromJson(String source) =>
      CameraCalibration.fromMap(json.decode(source));
}
