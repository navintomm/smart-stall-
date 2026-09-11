import 'dart:math' as math;
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:async';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../models/camera_calibration.dart';
import '../models/marker_pose.dart';
import '../models/aruco_detection_result.dart';

class ArucoPoseRequest {
  final Uint8List imageBytes;
  final int width;
  final int height;
  final int rowStride;
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
    this.targetMarkerId = -1,
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
  
  final String grayscaleConversionStatus;
  final String opencvMatDimensions;
  final int detectionDurationMs;

  ArucoPoseResponse({
    required this.allDetections,
    this.activeDetection,
    this.activePose,
    this.grayscaleConversionStatus = 'Unknown',
    this.opencvMatDimensions = 'Unknown',
    this.detectionDurationMs = 0,
  });
}

class ArucoPoseService {
  static final ArucoVisionWorker _worker = ArucoVisionWorker();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      await _worker.initialize();
      _initialized = true;
    }
  }

  static Future<void> dispose() async {
    if (_initialized) {
      _worker.dispose();
      _initialized = false;
    }
  }

  static Future<ArucoPoseResponse> detectAndEstimatePose(
      ArucoPoseRequest request) async {
    if (!_initialized) {
      await initialize();
    }
    return _worker.processFrame(request);
  }
}

class ArucoVisionWorker {
  SendPort? _sendPort;
  Isolate? _isolate;
  bool _isReady = false;
  int _messageId = 0;
  final Map<int, Completer<ArucoPoseResponse>> _completers = {};
  ReceivePort? _receivePort;

  Future<void> initialize() async {
    if (_isReady) return;
    
    _receivePort = ReceivePort();
    _receivePort!.listen(_handleMessage);
    
    _isolate = await Isolate.spawn(_workerLoop, _receivePort!.sendPort);
    // The worker will send back its SendPort as the first message
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isReady = true;
      return;
    }

    if (message is List) {
      final id = message[0] as int;
      final response = message[1] as ArucoPoseResponse;
      final completer = _completers.remove(id);
      completer?.complete(response);
    }
  }

  Future<ArucoPoseResponse> processFrame(ArucoPoseRequest request) async {
    if (!_isReady || _sendPort == null) {
      // If not fully initialized, wait or fail gracefully
      while (!_isReady) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    final id = _messageId++;
    final completer = Completer<ArucoPoseResponse>();
    _completers[id] = completer;

    _sendPort!.send([id, request]);

    return completer.future;
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    _isReady = false;
  }

  static void _workerLoop(SendPort mainSendPort) {
    final workerReceivePort = ReceivePort();
    mainSendPort.send(workerReceivePort.sendPort);

    cv.ArucoDictionary? dict;
    cv.ArucoDetectorParameters? params;
    cv.ArucoDetector? detector;
    bool detectorInitialized = false;

    void initDetector(cv.PredefinedDictionaryType dictType) {
      if (detectorInitialized) return;
      dict = cv.ArucoDictionary.predefined(dictType);
      params = cv.ArucoDetectorParameters.empty()
        ..adaptiveThreshWinSizeMin = 3
        ..adaptiveThreshWinSizeMax = 23
        ..adaptiveThreshWinSizeStep = 10
        ..minMarkerPerimeterRate = 0.05
        ..maxMarkerPerimeterRate = 4.0
        ..errorCorrectionRate = 0.6;
      detector = cv.ArucoDetector.create(dict!, params!);
      detectorInitialized = true;
    }

    workerReceivePort.listen((message) {
      if (message is List) {
        final id = message[0] as int;
        final request = message[1] as ArucoPoseRequest;

        try {
          initDetector(request.dictType);
          final response = _detectAndEstimatePoseSync(request, detector!);
          mainSendPort.send([id, response]);
        } catch (e) {
          // Send an empty response on error so the main thread doesn't hang
          mainSendPort.send([
            id,
            ArucoPoseResponse(allDetections: [], grayscaleConversionStatus: 'Worker Error: $e')
          ]);
        }
      }
    });
  }

  static ArucoPoseResponse _detectAndEstimatePoseSync(
      ArucoPoseRequest request, cv.ArucoDetector detector) {
    final startTime = DateTime.now();
    String conversionStatus = 'Pending';
    String matDims = 'Unknown';
    cv.Mat? grayMat;
    cv.VecVecPoint2f? cornersList;
    cv.VecI32? idsList;

    try {
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
        conversionStatus = 'SUCCESS (Stride Handled)';
      } else {
        conversionStatus = 'SUCCESS (Direct)';
      }

      grayMat = cv.Mat.fromList(
        request.height,
        request.width,
        cv.MatType.CV_8UC1,
        processedBytes,
      );
      matDims = '${grayMat.cols}x${grayMat.rows}';

      final result = detector.detectMarkers(grayMat);
      cornersList = result.$1;
      idsList = result.$2;

      final detectionDuration = DateTime.now().difference(startTime).inMilliseconds;

      if (idsList.isEmpty) {
        return ArucoPoseResponse(
          allDetections: [],
          activeDetection: null,
          activePose: null,
          grayscaleConversionStatus: conversionStatus,
          opencvMatDimensions: matDims,
          detectionDurationMs: detectionDuration,
        );
      }

      List<ArucoDetectionResult> allDetections = [];
      int bestTargetIndex = -1;
      double bestTargetScore = -1.0;

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

        // Basic 2D planar rotation approximation
        final dy = p1.y - p0.y;
        final dx = p1.x - p0.x;
        final angleRad = math.atan2(dy, dx);
        final angleDeg = angleRad * 180.0 / math.pi;

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
          semanticName: 'ID $id',
        );
        allDetections.add(detection);

        double score = 0.0;
        if (request.targetMarkerId != -1 && id == request.targetMarkerId) {
          score = 1000000.0 + pw;
        } else if (id == 1 || id == 10 || id == 20) {
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
        return ArucoPoseResponse(
          allDetections: allDetections,
          activeDetection: null,
          activePose: null,
          grayscaleConversionStatus: conversionStatus,
          opencvMatDimensions: matDims,
          detectionDurationMs: detectionDuration,
        );
      }

      final activeDetection = allDetections[bestTargetIndex];
      final hasCalibration = request.calibration != null && request.calibration!.isValid;

      if (!hasCalibration || request.calibration!.imageWidth == 0 || request.calibration!.imageHeight == 0) {
        return ArucoPoseResponse(
          allDetections: allDetections,
          activeDetection: activeDetection,
          activePose: null,
          grayscaleConversionStatus: conversionStatus,
          opencvMatDimensions: matDims,
          detectionDurationMs: detectionDuration,
        );
      }

      // ─── 3D Pose Estimation via solvePnP ────────────────────────────────

      final scaleX = request.width / request.calibration!.imageWidth;
      final scaleY = request.height / request.calibration!.imageHeight;

      final double fx = request.calibration!.cameraMatrix[0][0] * scaleX;
      final double fy = request.calibration!.cameraMatrix[1][1] * scaleY;
      final double cx = request.calibration!.cameraMatrix[0][2] * scaleX;
      final double cy = request.calibration!.cameraMatrix[1][2] * scaleY;

      double physicalSize = request.knownMarkerSizes[activeDetection.markerId] ?? request.defaultMarkerSizeMeters;
      if (physicalSize <= 0) physicalSize = request.defaultMarkerSizeMeters;

      final double halfSize = physicalSize / 2.0;

      // 3D Object points (4 points, 3 coordinates each)
      final objPoints = cv.Mat.fromList(4, 3, cv.MatType.CV_64FC1, [
        -halfSize, halfSize, 0.0,
        halfSize, halfSize, 0.0,
        halfSize, -halfSize, 0.0,
        -halfSize, -halfSize, 0.0,
      ]);

      // 2D Image points (4 points, 2 coordinates each)
      final imgPoints = cv.Mat.fromList(4, 2, cv.MatType.CV_64FC1, [
        activeDetection.corners[0].x.toDouble(), activeDetection.corners[0].y.toDouble(),
        activeDetection.corners[1].x.toDouble(), activeDetection.corners[1].y.toDouble(),
        activeDetection.corners[2].x.toDouble(), activeDetection.corners[2].y.toDouble(),
        activeDetection.corners[3].x.toDouble(), activeDetection.corners[3].y.toDouble(),
      ]);

      // Camera Matrix Mat
      final cameraMatrixMat = cv.Mat.fromList(3, 3, cv.MatType.CV_64FC1, [
        fx, 0.0, cx,
        0.0, fy, cy,
        0.0, 0.0, 1.0
      ]);

      // Distortion Coefficients
      final distCoeffsMat = cv.Mat.zeros(4, 1, cv.MatType.CV_64FC1);

      MarkerPose? pose;

      try {
        final resultPnp = cv.solvePnP(
          objPoints,
          imgPoints,
          cameraMatrixMat,
          distCoeffsMat,
          flags: cv.SOLVEPNP_IPPE_SQUARE
        );

        final success = resultPnp.$1;
        final rvec = resultPnp.$2;
        final tvec = resultPnp.$3;

        if (success) {
          final Float64List tvecData = tvec.data.buffer.asFloat64List();
          final double tX = tvecData[0];
          final double tY = tvecData[1];
          final double tZ = tvecData[2];

          // If Rodrigues returns a single Mat or a tuple
          // Let's assume it returns a tuple of (Mat dst, Mat jacobian) based on standard OpenCV, 
          // but if it returned a single Mat it would be erroring on $1.
          // Wait, the error is: The getter '$1' isn't defined for the type 'Mat'
          // So Rodrigues returns a single Mat!
          final rotMat = cv.Rodrigues(rvec);
          final Float64List rotData = rotMat.data.buffer.asFloat64List();
          
          final r11 = rotData[0];
          final r21 = rotData[3];
          final r31 = rotData[6];
          final r32 = rotData[7];
          final r33 = rotData[8];

          final pitch = math.atan2(-r31, math.sqrt(r32 * r32 + r33 * r33)) * 180.0 / math.pi;
          final yaw = math.atan2(r21, r11) * 180.0 / math.pi;
          final roll = math.atan2(r32, r33) * 180.0 / math.pi;

          pose = MarkerPose(
            x: tX,
            y: tY,
            z: tZ,
            roll: roll,
            pitch: pitch,
            yaw: yaw,
          );

          rotMat.dispose();
        }

        rvec.dispose();
        tvec.dispose();
      } catch (e) {
        // Fallback to simple distance if solvePnP fails/crashes
        final distanceM = (physicalSize * fx) / activeDetection.pixelWidth;
        final xM = (activeDetection.center.x - cx) * distanceM / fx;
        final yM = (activeDetection.center.y - cy) * distanceM / fy;
        pose = MarkerPose(
          x: xM, y: yM, z: distanceM, roll: 0.0, pitch: 0.0, yaw: activeDetection.rotationDeg
        );
      } finally {
        objPoints.dispose();
        imgPoints.dispose();
        cameraMatrixMat.dispose();
        distCoeffsMat.dispose();
      }

      return ArucoPoseResponse(
        allDetections: allDetections,
        activeDetection: activeDetection,
        activePose: pose,
        grayscaleConversionStatus: conversionStatus,
        opencvMatDimensions: matDims,
        detectionDurationMs: detectionDuration,
      );
    } finally {
      grayMat?.dispose();
      cornersList?.dispose();
      idsList?.dispose();
    }
  }
}
