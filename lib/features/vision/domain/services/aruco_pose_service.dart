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
  final double markerSizeMeters;
  final CameraCalibration? calibration;
  final cv.PredefinedDictionaryType dictType;

  ArucoPoseRequest({
    required this.imageBytes,
    required this.width,
    required this.height,
    required this.rowStride,
    this.targetMarkerId = -1, // -1 = accept any marker
    required this.markerSizeMeters,
    this.calibration,
    this.dictType = cv.PredefinedDictionaryType.DICT_4X4_50,
  });
}

class ArucoPoseResponse {
  final ArucoDetectionResult? detection;
  final MarkerPose? pose;

  ArucoPoseResponse({this.detection, this.pose});
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
          return ArucoPoseResponse(detection: null, pose: null);
        }

        // Pick the best marker:
        // - If targetMarkerId == -1 → pick any (choose the largest by pixel area).
        // - Otherwise → prefer the requested ID; fall back to largest if not found.
        int targetIndex = -1;
        double bestPixelWidth = -1.0;

        for (int i = 0; i < idsList.length; i++) {
          final corners = cornersList[i];
          final top = math.sqrt(
            math.pow(corners[1].x - corners[0].x, 2) +
            math.pow(corners[1].y - corners[0].y, 2),
          );
          final bottom = math.sqrt(
            math.pow(corners[2].x - corners[3].x, 2) +
            math.pow(corners[2].y - corners[3].y, 2),
          );
          final pw = (top + bottom) / 2.0;

          if (request.targetMarkerId != -1 && idsList[i] == request.targetMarkerId) {
            // Exact match — always prefer this one
            targetIndex = i;
            bestPixelWidth = pw;
            break;
          }

          if (pw > bestPixelWidth) {
            bestPixelWidth = pw;
            targetIndex = i;
          }
        }

        if (targetIndex == -1) {
          return ArucoPoseResponse(detection: null, pose: null);
        }

        final detectedId = idsList[targetIndex];
        final targetCorners = cornersList[targetIndex];
        final p0 = targetCorners[0]; // top-left
        final p1 = targetCorners[1]; // top-right
        final p2 = targetCorners[2]; // bottom-right
        final p3 = targetCorners[3]; // bottom-left

        final points = [
          math.Point<double>(p0.x, p0.y),
          math.Point<double>(p1.x, p1.y),
          math.Point<double>(p2.x, p2.y),
          math.Point<double>(p3.x, p3.y),
        ];

        final detection = ArucoDetectionResult(
          markerId: detectedId, // Report the ACTUAL detected ID
          corners: points,
          confidence: 1.0,
        );

        // 3. Pose Estimation using Pinhole Camera Model (from Android app)
        
        // Calculate pixel width (average of top and bottom edges)
        final topEdge = math.sqrt(math.pow(p1.x - p0.x, 2) + math.pow(p1.y - p0.y, 2));
        final bottomEdge = math.sqrt(math.pow(p2.x - p3.x, 2) + math.pow(p2.y - p3.y, 2));
        final pixelWidth = (topEdge + bottomEdge) / 2.0;

        // Hard filter on marker size
        if (pixelWidth < 20.0) {
          return ArucoPoseResponse(detection: null, pose: null); // Too small/far
        }

        final hasCalibration = request.calibration != null && request.calibration!.isValid;
        if (!hasCalibration) {
          // Uncalibrated -> distance/pose is unknown
          return ArucoPoseResponse(detection: detection, pose: null);
        }

        // Guard: legacy calibration records may have imageWidth/imageHeight = 0.
        // A zero stored dimension would cause divide-by-zero. Treat as needing recalibration.
        if (request.calibration!.imageWidth == 0 || request.calibration!.imageHeight == 0) {
          return ArucoPoseResponse(detection: detection, pose: null);
        }

        // Normalize focal length and optical center if resolution differs from calibration time.
        // scaleX = liveWidth / calibratedWidth, scaleY = liveHeight / calibratedHeight.
        final scaleX = request.width / request.calibration!.imageWidth;
        final scaleY = request.height / request.calibration!.imageHeight;

        final double fx = request.calibration!.cameraMatrix[0][0] * scaleX;
        final double fy = request.calibration!.cameraMatrix[1][1] * scaleY;
        final double cx = request.calibration!.cameraMatrix[0][2] * scaleX;
        final double cy = request.calibration!.cameraMatrix[1][2] * scaleY;

        // distance_m = (real_marker_size_m × focal_length_px) / marker_pixel_width
        final distanceM = (request.markerSizeMeters * fx) / pixelWidth;

        // Center point in pixels
        final centerX = (p0.x + p1.x + p2.x + p3.x) / 4.0;
        final centerY = (p0.y + p1.y + p2.y + p3.y) / 4.0;

        // Approximate X, Y in meters using pinhole projection
        final xM = (centerX - cx) * distanceM / fx;
        final yM = (centerY - cy) * distanceM / fy;
        final zM = distanceM;

        // Rotation angle of top edge
        final dy = p1.y - p0.y;
        final dx = p1.x - p0.x;
        final angleRad = math.atan2(dy, dx);
        final angleDeg = angleRad * 180.0 / math.pi;

        final pose = MarkerPose(
          x: xM,
          y: yM,
          z: zM,
          roll: 0.0,
          pitch: 0.0,
          yaw: angleDeg, // Map 2D rotation to yaw
        );

        return ArucoPoseResponse(detection: detection, pose: pose);
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
