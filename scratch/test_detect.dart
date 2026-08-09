import 'package:opencv_dart/opencv_dart.dart' as cv;

void main() {
  final dict = cv.ArucoDictionary.predefined(cv.PredefinedDictionaryType.DICT_4X4_50);
  final params = cv.ArucoDetectorParameters.empty();
  final detector = cv.ArucoDetector.create(dict, params);
  
  final mat = cv.Mat.zeros(100, 100, cv.MatType.CV_8UC1);
  final (corners, ids, rejected) = detector.detectMarkers(mat);
  
  print('ids.isEmpty: ${ids.isEmpty}');
  print('ids.length: ${ids.length}');
  
  if (ids.length > 0) {
    print('ids[0]: ${ids[0]}');
  } else {
    print('No ids found');
  }
}
