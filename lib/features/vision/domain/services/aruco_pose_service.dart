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
  final int targetMarkerId;
  final double markerSizeMeters;
  final CameraCalibration? calibration;
  final cv.PredefinedDictionaryType dictType;

  ArucoPoseRequest({
    required this.imageBytes,
    required this.width,
    required this.height,
    required this.targetMarkerId,
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
  /// Detects ArUco marker and estimates pose. Runs entirely in a background isolate.
  static Future<ArucoPoseResponse> detectAndEstimatePose(
      ArucoPoseRequest request) async {
    return Isolate.run(() {
      cv.Mat? grayMat;
      cv.ArucoDetector? detector;
      cv.Mat? cameraMatrixMat;
      cv.Mat? distCoeffsMat;
      cv.Mat? rvec;
      cv.Mat? tvec;
      cv.Mat? rotMat;

      try {
        // 1. Create Grayscale Mat from Y-plane bytes
        grayMat = cv.Mat.fromList(
          request.height,
          request.width,
          cv.MatType.CV_8UC1,
          request.imageBytes,
        );

        // 2. Detect ArUco Marker
        final dict = cv.ArucoDictionary.predefined(request.dictType);
        final params = cv.ArucoDetectorParameters.empty();
        detector = cv.ArucoDetector.create(dict, params);

        final (cornersList, idsList, _) = detector.detectMarkers(grayMat);

        if (idsList.isEmpty) {
          return ArucoPoseResponse(detection: null, pose: null);
        }

        // Find the target marker
        int targetIndex = -1;
        for (int i = 0; i < idsList.length; i++) {
          if (idsList[i] == request.targetMarkerId) {
            targetIndex = i;
            break;
          }
        }

        if (targetIndex == -1) {
          // Target marker not found
          return ArucoPoseResponse(detection: null, pose: null);
        }

        final targetCorners = cornersList[targetIndex]; // VecPoint2f
        final points = [
          targetCorners[0],
          targetCorners[1],
          targetCorners[2],
          targetCorners[3],
        ];

        final detection = ArucoDetectionResult(
          markerId: request.targetMarkerId,
          corners: points,
          confidence: 1.0, // Base confidence, could be filtered temporally later
        );

        // 3. Pose Estimation (if calibrated)
        MarkerPose? pose;
        if (request.calibration != null && request.calibration!.isValid) {
          // 3D object points in marker coordinate system (Z=0, origin at center)
          final halfSize = request.markerSizeMeters / 2.0;
          final objPointsMat = cv.Mat.from2DList([
            <double>[-halfSize, halfSize, 0.0],
            <double>[halfSize, halfSize, 0.0],
            <double>[halfSize, -halfSize, 0.0],
            <double>[-halfSize, -halfSize, 0.0],
          ], cv.MatType.CV_32FC1);
          
          final targetCornersMat = cv.Mat.from2DList([
            <double>[targetCorners[0].x, targetCorners[0].y],
            <double>[targetCorners[1].x, targetCorners[1].y],
            <double>[targetCorners[2].x, targetCorners[2].y],
            <double>[targetCorners[3].x, targetCorners[3].y],
          ], cv.MatType.CV_32FC1);
          
          // Build Camera Matrix
          cameraMatrixMat = cv.Mat.zeros(3, 3, cv.MatType.CV_64FC1);
          for (int r = 0; r < 3; r++) {
            for (int c = 0; c < 3; c++) {
              cameraMatrixMat.set<double>(r, c, request.calibration!.cameraMatrix[r][c]);
            }
          }
          
          // Build Distortion Coefficients
          distCoeffsMat = cv.Mat.zeros(request.calibration!.distCoeffs.length, 1, cv.MatType.CV_64FC1);
          for (int i = 0; i < request.calibration!.distCoeffs.length; i++) {
            distCoeffsMat.set<double>(i, 0, request.calibration!.distCoeffs[i]);
          }

          final (solved, rvecRes, tvecRes) = cv.solvePnP(
            objPointsMat,
            targetCornersMat,
            cameraMatrixMat,
            distCoeffsMat,
          );

          if (solved) {
            rvec = rvecRes;
            tvec = tvecRes;

            // tvec is translation (x,y,z) in meters
            final tx = tvec.at<double>(0, 0);
            final ty = tvec.at<double>(1, 0);
            final tz = tvec.at<double>(2, 0);

            // rvec is rotation vector, convert to rotation matrix
            rotMat = cv.Rodrigues(rvec);

            // Extract Euler angles (roll, pitch, yaw) from rotation matrix
            final r32 = rotMat.at<double>(2, 1);
            final r33 = rotMat.at<double>(2, 2);
            final r31 = rotMat.at<double>(2, 0);
            final r21 = rotMat.at<double>(1, 0);
            final r11 = rotMat.at<double>(0, 0);

            // Standard conversion from Rotation Matrix to Euler angles (in radians)
            // Assuming XYZ order
            final pitchRad = -math.asin(r31);
            final rollRad = math.atan2(r32, r33);
            final yawRad = math.atan2(r21, r11);

            // Convert to degrees
            final pitch = pitchRad * 180.0 / math.pi;
            final roll = rollRad * 180.0 / math.pi;
            final yaw = yawRad * 180.0 / math.pi;

            pose = MarkerPose(
              x: tx,
              y: ty,
              z: tz,
              roll: roll,
              pitch: pitch,
              yaw: yaw,
            );
          }
          
          objPointsMat.dispose();
          targetCornersMat.dispose();
        }

        return ArucoPoseResponse(detection: detection, pose: pose);
      } finally {
        // IMPORTANT: Prevent memory leaks
        grayMat?.dispose();
        cameraMatrixMat?.dispose();
        distCoeffsMat?.dispose();
        rvec?.dispose();
        tvec?.dispose();
        rotMat?.dispose();
      }
    });
  }
}
