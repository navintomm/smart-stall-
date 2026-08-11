import 'dart:math' as math;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../models/camera_calibration.dart';
import '../models/marker_pose.dart';
import '../models/aruco_detection_result.dart';

class ArucoPoseRequest {
  final Uint8List imageBytes;
  final int width;
  final int height;
  final int rowStride;
  /// Set to -1 to accept any detected marker.
  final int targetMarkerId;
  final double defaultMarkerSizeMeters;
  final Map<int, double> knownMarkerSizes;
  final CameraCalibration? calibration;
  final cv.PredefinedDictionaryType dictType;

  ArucoPoseRequest({
    required this.imageBytes,
    required this.width,
    required this.height,
    required this.rowStride,
    this.targetMarkerId = -1, // -1 = accept any marker
    required this.defaultMarkerSizeMeters,
    this.knownMarkerSizes = const {},
    this.calibration,
    this.dictType = cv.PredefinedDictionaryType.DICT_4X4_50,
  });
}

class ArucoPoseResponse {
  final List<ArucoDetectionResult> allDetections;
  final ArucoDetectionResult? activeDetection;
  final MarkerPose? activePose;

  ArucoPoseResponse({
    required this.allDetections,
    this.activeDetection,
    this.activePose,
  });
}

class ArucoPoseService {
  static Future<ArucoPoseResponse> detectAndEstimatePose(
      ArucoPoseRequest request) async {
    return Isolate.run(() {
      cv.Mat? grayMat;
      cv.ArucoDictionary? dict;
      cv.ArucoDetectorParameters? params;
      cv.ArucoDetector? detector;
      cv.VecVecPoint2f? cornersList;
      cv.VecI32? idsList;

      try {
        // 1. Create Grayscale Mat from Y-plane bytes, handling row stride padding
        Uint8List processedBytes = request.imageBytes;
        if (request.rowStride > request.width) {
          processedBytes = Uint8List(request.width * request.height);
          for (int i = 0; i < request.height; i++) {
            processedBytes.setRange(
              i * request.width, 
              (i + 1) * request.width, 
              request.imageBytes, 
              i * request.rowStride
            );
          }
        }

        grayMat = cv.Mat.fromList(
          request.height,
          request.width,
          cv.MatType.CV_8UC1,
          processedBytes,
        );

        // 2. Detect ArUco Marker with tuned parameters from Android app
        dict = cv.ArucoDictionary.predefined(request.dictType);
        params = cv.ArucoDetectorParameters.empty()
          ..adaptiveThreshWinSizeMin = 3
          ..adaptiveThreshWinSizeMax = 23
          ..adaptiveThreshWinSizeStep = 10
          ..minMarkerPerimeterRate = 0.05
          ..maxMarkerPerimeterRate = 4.0
          ..errorCorrectionRate = 0.6;
          
        detector = cv.ArucoDetector.create(dict, params);

        final result = detector.detectMarkers(grayMat);
        cornersList = result.$1;
        idsList = result.$2;

        if (idsList.isEmpty) {
          return ArucoPoseResponse(allDetections: [], activeDetection: null, activePose: null);
        }

        List<ArucoDetectionResult> allDetections = [];
        int bestTargetIndex = -1;
        double bestTargetScore = -1.0;
        
        // Strategy Priorities:
        // 1. Explicitly requested target marker
        // 2. Registered marker (highest priority score)
        // 3. Largest marker

        for (int i = 0; i < idsList.length; i++) {
          final id = idsList[i];
          final corners = cornersList[i];
          final p0 = corners[0];
          final p1 = corners[1];
          final p2 = corners[2];
          final p3 = corners[3];

          final top = math.sqrt(math.pow(p1.x - p0.x, 2) + math.pow(p1.y - p0.y, 2));
          final bottom = math.sqrt(math.pow(p2.x - p3.x, 2) + math.pow(p2.y - p3.y, 2));
          final left = math.sqrt(math.pow(p3.x - p0.x, 2) + math.pow(p3.y - p0.y, 2));
          final right = math.sqrt(math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2));
          
          final pw = (top + bottom) / 2.0;
          final ph = (left + right) / 2.0;
          
          final centerX = (p0.x + p1.x + p2.x + p3.x) / 4.0;
          final centerY = (p0.y + p1.y + p2.y + p3.y) / 4.0;
          
          final dy = p1.y - p0.y;
          final dx = p1.x - p0.x;
          final angleRad = math.atan2(dy, dx);
          final angleDeg = angleRad * 180.0 / math.pi;

          // Placeholder label and size. In a real app we'd pass this via request, 
          // but we can't easily import MarkerRegistry inside Isolate.run if it relies on Flutter logic.
          // However, we just need basic info here, and can enrich it back on the main thread, 
          // but let's assume we pass the physical sizes from the main thread if needed, or we calculate pose later.
          // Actually, let's keep it simple: Isolate just returns all detections.
          final detection = ArucoDetectionResult(
            markerId: id,
            corners: [
              math.Point<double>(p0.x, p0.y),
              math.Point<double>(p1.x, p1.y),
              math.Point<double>(p2.x, p2.y),
              math.Point<double>(p3.x, p3.y),
            ],
            center: math.Point<double>(centerX, centerY),
            pixelWidth: pw,
            pixelHeight: ph,
            rotationDeg: angleDeg,
            confidence: 1.0,
            semanticName: 'ID $id', // We will enrich this outside the isolate
          );
          allDetections.add(detection);

          // Selection Strategy Scoring
          double score = 0.0;
          if (request.targetMarkerId != -1 && id == request.targetMarkerId) {
            score = 1000000.0 + pw; // Top priority
          } else if (id == 1 || id == 10 || id == 20) { // Known registered markers
            score = 500000.0 + pw;
          } else {
            score = pw;
          }

          if (score > bestTargetScore) {
            bestTargetScore = score;
            bestTargetIndex = i;
          }
        }

        if (bestTargetIndex == -1 || allDetections[bestTargetIndex].pixelWidth < 20.0) {
          return ArucoPoseResponse(allDetections: allDetections, activeDetection: null, activePose: null);
        }

        final activeDetection = allDetections[bestTargetIndex];
        
        final hasCalibration = request.calibration != null && request.calibration!.isValid;
        if (!hasCalibration || request.calibration!.imageWidth == 0 || request.calibration!.imageHeight == 0) {
          return ArucoPoseResponse(allDetections: allDetections, activeDetection: activeDetection, activePose: null);
        }

        final scaleX = request.width / request.calibration!.imageWidth;
        final scaleY = request.height / request.calibration!.imageHeight;

        final double fx = request.calibration!.cameraMatrix[0][0] * scaleX;
        final double fy = request.calibration!.cameraMatrix[1][1] * scaleY;
        final double cx = request.calibration!.cameraMatrix[0][2] * scaleX;
        final double cy = request.calibration!.cameraMatrix[1][2] * scaleY;

        // Use physical size for this specific marker. If not configured, use default.
        double physicalSize = request.knownMarkerSizes[activeDetection.markerId] ?? request.defaultMarkerSizeMeters;
        if (physicalSize <= 0) physicalSize = request.defaultMarkerSizeMeters;

        final distanceM = (physicalSize * fx) / activeDetection.pixelWidth;

        final xM = (activeDetection.center.x - cx) * distanceM / fx;
        final yM = (activeDetection.center.y - cy) * distanceM / fy;
        final zM = distanceM;

        final pose = MarkerPose(
          x: xM,
          y: yM,
          z: zM,
          roll: 0.0,
          pitch: 0.0,
          yaw: activeDetection.rotationDeg,
        );

        return ArucoPoseResponse(
          allDetections: allDetections, 
          activeDetection: activeDetection, 
          activePose: pose,
        );
      } finally {
        grayMat?.dispose();
        detector?.dispose();
        dict?.dispose();
        params?.dispose();
        cornersList?.dispose();
        idsList?.dispose();
      }
    });
  }
}
