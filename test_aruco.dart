// ignore_for_file: avoid_print
import 'package:opencv_dart/opencv_dart.dart' as cv;

void main() {
  print('Trying empty...');
  final params = cv.ArucoDetectorParameters.empty();
  print('minMarkerPerimeterRate: ${params.minMarkerPerimeterRate}');
  print('polygonalApproxAccuracyRate: ${params.polygonalApproxAccuracyRate}');
  
  // Create a dummy mat
  final mat = cv.Mat.zeros(100, 100, cv.MatType.CV_8UC1);
  final dict = cv.ArucoDictionary.predefined(cv.PredefinedDictionaryType.DICT_4X4_50);
  final detector = cv.ArucoDetector.create(dict, params);
  final result = detector.detectMarkers(mat);
  print('Detected: ${result.$2.length}');
}
