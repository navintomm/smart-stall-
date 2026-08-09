import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:smartstall_operator/core/theme/app_colors.dart';
import 'package:smartstall_operator/core/constants/vision_constants.dart';
import 'package:smartstall_operator/features/vision/domain/services/camera_calibration_service.dart';
import 'package:smartstall_operator/features/vision/domain/models/camera_calibration.dart';
import 'package:smartstall_operator/features/vision/presentation/providers/calibration_provider.dart';

class CameraCalibrationPage extends ConsumerStatefulWidget {
  const CameraCalibrationPage({super.key});

  @override
  ConsumerState<CameraCalibrationPage> createState() => _CameraCalibrationPageState();
}

class _CameraCalibrationPageState extends ConsumerState<CameraCalibrationPage> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  bool _isCalibrating = false;
  int _framesCaptured = 0;
  static const int _requiredFrames = 15;

  // Calibration points
  final List<cv.VecPoint3f> _objectPointsList = [];
  final List<cv.VecPoint2f> _imagePointsList = [];
  
  // Base object points for one checkerboard
  late final cv.VecPoint3f _checkerboardObjPoints;

  cv.VecPoint2f? _currentCorners;
  Size? _imageSize;

  // The background isolate calibration requires bytes instead of cv.Mat
  @override
  void initState() {
    super.initState();
    _initializeObjectPoints();
    _initializeCamera();
  }

  void _initializeObjectPoints() {
    final List<cv.Point3f> points = [];
    for (int i = 0; i < VisionConstants.checkerboardRows; i++) {
      for (int j = 0; j < VisionConstants.checkerboardColumns; j++) {
        points.add(cv.Point3f(
          j * VisionConstants.checkerboardSquareSizeMeters,
          i * VisionConstants.checkerboardSquareSizeMeters,
          0.0,
        ));
      }
    }
    _checkerboardObjPoints = cv.VecPoint3f.fromList(points);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final rearCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      rearCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    
    // Lock focus and exposure if possible
    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (_) {}

    if (mounted) {
      setState(() {});
      _cameraController!.startImageStream(_processFrame);
    }
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing || _isCalibrating) return;
    _isProcessing = true;

    try {
      final width = image.width;
      final height = image.height;
      _imageSize = Size(width.toDouble(), height.toDouble());

      final lumaPlane = image.planes[0];
      final mat = cv.Mat.fromList(height, width, cv.MatType.CV_8UC1, lumaPlane.bytes);

      final (found, corners) = cv.findChessboardCorners(
        mat, 
        (VisionConstants.checkerboardColumns, VisionConstants.checkerboardRows)
      );

      mat.dispose();

      if (mounted) {
        setState(() {
          _currentCorners = found ? corners : null;
        });
      }

    } catch (e) {
      // Ignore
    } finally {
      _isProcessing = false;
    }
  }

  void _captureFrame() {
    if (_currentCorners == null || _imageSize == null) return;
    
    // Make a copy of the corners
    _imagePointsList.add(_currentCorners!);
    _objectPointsList.add(_checkerboardObjPoints);

    setState(() {
      _framesCaptured++;
    });

    if (_framesCaptured >= _requiredFrames) {
      _runCalibration();
    }
  }

  Future<void> _runCalibration() async {
    setState(() {
      _isCalibrating = true;
    });

    // Convert List to VecVec
    final objPointsVecVec = cv.VecVecPoint3f.fromList(
      _objectPointsList.map((e) => e.toList()).toList()
    );
    
    final imgPointsVecVec = cv.VecVecPoint2f.fromList(
      _imagePointsList.map((e) => e.toList()).toList()
    );

    final cameraMatrixInit = cv.Mat.empty();
    final distCoeffsInit = cv.Mat.empty();

    try {
      final (reprojectionError, cameraMatrix, distCoeffs, _, _) = cv.calibrateCamera(
        objPointsVecVec,
        imgPointsVecVec,
        (_imageSize!.width.toInt(), _imageSize!.height.toInt()),
        cameraMatrixInit,
        distCoeffsInit,
      );

      // Convert camera matrix to List<List<double>>
      final camMatList = <List<double>>[];
      for (int r = 0; r < 3; r++) {
        final row = <double>[];
        for (int c = 0; c < 3; c++) {
          row.add(cameraMatrix.at<double>(r, c));
        }
        camMatList.add(row);
      }

      // Convert distCoeffs to List<double>
      final distList = <double>[];
      for (int i = 0; i < distCoeffs.rows * distCoeffs.cols; i++) {
        distList.add(distCoeffs.at<double>(0, i));
      }

      // Save to provider
      final calib = CameraCalibration(
        cameraMatrix: camMatList,
        distCoeffs: distList,
        reprojectionError: reprojectionError,
        imageWidth: _imageSize!.width.toInt(),
        imageHeight: _imageSize!.height.toInt(),
        isValid: true,
      );

      await ref.read(calibrationProvider.notifier).saveCalibration(calib);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Calibration Successful"),
            content: Text("Reprojection Error: ${reprojectionError.toStringAsFixed(3)}\n\nCalibration saved successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Calibration failed: $e")),
        );
      }
      setState(() {
        _isCalibrating = false;
        _framesCaptured = 0;
        _imagePointsList.clear();
        _objectPointsList.clear();
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Camera Calibration"),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          
          // Checkerboard Overlay
          if (_currentCorners != null && _imageSize != null)
            Positioned.fill(
              child: CustomPaint(
                painter: CheckerboardPainter(
                  corners: _currentCorners!,
                  imageSize: _imageSize!,
                  color: AppColors.successGreen,
                ),
              ),
            ),
            
          // Instructions & Progress
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Captured: $_framesCaptured / $_requiredFrames",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Move the 7x5 checkerboard to different angles and distances.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          
          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _isCalibrating
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : InkWell(
                      onTap: _currentCorners != null ? _captureFrame : null,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentCorners != null ? AppColors.primary : Colors.grey,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}

class CheckerboardPainter extends CustomPainter {
  final cv.VecPoint2f corners;
  final Size imageSize;
  final Color color;

  CheckerboardPainter({
    required this.corners,
    required this.imageSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.height; // Note: Android rear camera stream is usually 90deg rotated
    final scaleY = size.height / imageSize.width;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final corner in corners) {
      // Rotate coordinates for portrait mode (assuming phone is in portrait)
      // Original frame is landscape (e.g., 640x480).
      final x = corner.y * scaleX; 
      final y = (imageSize.width - corner.x) * scaleY;
      
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CheckerboardPainter oldDelegate) => true;
}
