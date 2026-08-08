import 'dart:isolate';
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../models/camera_calibration.dart';

class CalibrationRequest {
  final List<Uint8List> imageBytesList;
  final int width;
  final int height;
  final int cols; // Inner corners (e.g., 7)
  final int rows; // Inner corners (e.g., 5)
  final double squareSizeMeters; // e.g., 0.03 for 30mm

  CalibrationRequest({
    required this.imageBytesList,
    required this.width,
    required this.height,
    required this.cols,
    required this.rows,
    required this.squareSizeMeters,
  });
}

class CameraCalibrationService {
  /// Processes checkerboard images and returns a CameraCalibration.
  /// Runs entirely in a background isolate.
  static Future<CameraCalibration> calibrate(CalibrationRequest request) async {
    return Isolate.run(() {
      final objPointsList = <List<cv.Point3f>>[];
      final imgPointsList = <List<cv.Point2f>>[];
      final matsToDispose = <cv.Mat>[];

      // Build the standard object points for the checkerboard
      final objp = <cv.Point3f>[];
      for (int i = 0; i < request.rows; i++) {
        for (int j = 0; j < request.cols; j++) {
          objp.add(cv.Point3f(
            j * request.squareSizeMeters,
            i * request.squareSizeMeters,
            0.0,
          ));
        }
      }

      final criteria = cv.TermCriteria(
        cv.TERM_COUNT + cv.TERM_EPS,
        30,
        0.1,
      );

      try {
        for (final bytes in request.imageBytesList) {
          final grayMat = cv.Mat.fromList(
            request.height,
            request.width,
            cv.MatType.CV_8UC1,
            bytes,
          );
          matsToDispose.add(grayMat);

          final (found, cornersVec) = cv.findChessboardCorners(
            grayMat,
            (request.cols, request.rows),
          );

          if (found) {
            // Refine corner locations
            cv.cornerSubPix(
              grayMat,
              cornersVec,
              (11, 11),
              (-1, -1),
              (cv.TERM_COUNT + cv.TERM_EPS, 30, 0.1),
            );

            // Need to convert VecPoint2f back to a dart List to store it easily
            final cornersList = <cv.Point2f>[];
            for (int i = 0; i < cornersVec.length; i++) {
              cornersList.add(cornersVec[i]);
            }
            imgPointsList.add(cornersList);
            objPointsList.add(objp);
          }
        }

        if (imgPointsList.isEmpty) {
          return CameraCalibration.empty();
        }

        final objVecVec = cv.VecVecPoint3f.fromList(objPointsList);
        final imgVecVec = cv.VecVecPoint2f.fromList(imgPointsList);
        
        final cameraMatrix = cv.Mat.empty();
        final distCoeffs = cv.Mat.empty();
        
        matsToDispose.add(cameraMatrix);
        matsToDispose.add(distCoeffs);

        final (rmsErr, camMat, dist, rvecs, tvecs) = cv.calibrateCamera(
          objVecVec,
          imgVecVec,
          (request.width, request.height),
          cameraMatrix,
          distCoeffs,
        );
        
        matsToDispose.add(rvecs);
        matsToDispose.add(tvecs);

        // Convert camera matrix to List<List<double>>
        final camMatList = <List<double>>[];
        for (int r = 0; r < 3; r++) {
          final row = <double>[];
          for (int c = 0; c < 3; c++) {
            row.add(camMat.at<double>(r, c));
          }
          camMatList.add(row);
        }

        // Convert distCoeffs to List<double>
        final distList = <double>[];
        for (int i = 0; i < dist.rows * dist.cols; i++) {
          distList.add(dist.at<double>(i, 0));
        }

        objVecVec.dispose();
        imgVecVec.dispose();

        return CameraCalibration(
          cameraMatrix: camMatList,
          distCoeffs: distList,
          reprojectionError: rmsErr,
          imageWidth: request.width,
          imageHeight: request.height,
          isValid: true,
        );
      } catch (e) {
        print('Calibration error: $e');
        return CameraCalibration.empty();
      } finally {
        for (final mat in matsToDispose) {
          mat.dispose();
        }
      }
    });
  }
}
