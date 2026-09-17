import 'package:opencv_dart/opencv_dart.dart' as cv;

void main() {
  final mat = cv.Mat.zeros(3, 1, cv.MatType.CV_64FC1);
  try {
    final v1 = mat.at<double>(0, 0);
    print('v1: $v1');
  } catch(e) {
    print('Error at<double>: $e');
  }
}
