import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ArucoScannerScreen extends StatefulWidget {
  const ArucoScannerScreen({super.key});

  @override
  State<ArucoScannerScreen> createState() => _ArucoScannerScreenState();
}

class _ArucoScannerScreenState extends State<ArucoScannerScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  
  List<cv.Point2f> _markerCorners = [];
  String _distanceText = "Scanning...";
  int? _detectedId;

  late cv.ArucoDetector _detector;

  @override
  void initState() {
    super.initState();
    _initializeVision();
    _initializeCamera();
  }

  void _initializeVision() {
    final dict = cv.ArucoDictionary.predefined(cv.PredefinedDictionaryType.DICT_4X4_50);
    final params = cv.ArucoDetectorParameters.empty();
    _detector = cv.ArucoDetector.create(dict, params);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final rearCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        rearCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Provides grayscale in plane 0
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {});
        _controller!.startImageStream(_processCameraFrame);
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  void _processCameraFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Y plane contains grayscale data
      final plane = image.planes[0];
      final mat = cv.Mat.fromList(
        image.height,
        image.width,
        cv.MatType.CV_8UC1,
        plane.bytes,
      );

      // Detect markers
      final (corners, ids, _) = _detector.detectMarkers(mat);

      if (ids.isNotEmpty && corners.isNotEmpty) {
        final markerCorners = corners.first;
        final markerId = ids.first;
        
        // Approximate distance based on known marker size (150mm)
        // Focal length approximation: ~800 pixels
        // Dist = (Actual Size * Focal Length) / Pixel Size
        
        // Calculate pixel width of the marker
        final pt1 = markerCorners[0];
        final pt2 = markerCorners[1];
        final pixelWidth = sqrt(pow(pt2.x - pt1.x, 2) + pow(pt2.y - pt1.y, 2));
        
        double distance = 0.0;
        if (pixelWidth > 0) {
          distance = (0.15 * 800) / pixelWidth; // in meters
        }

        if (mounted) {
          setState(() {
            _detectedId = markerId;
            _distanceText = "${distance.toStringAsFixed(2)}m";
            _markerCorners = [
              markerCorners[0],
              markerCorners[1],
              markerCorners[2],
              markerCorners[3],
            ];
          });
        }
      } else {
        if (mounted && _detectedId != null) {
          setState(() {
            _detectedId = null;
            _distanceText = "Scanning...";
            _markerCorners = [];
          });
        }
      }

      mat.dispose();
    } catch (e) {
      debugPrint("Vision error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const NavigationHeader(
              title: 'ArUco Scanner',
              icon: AppIcons.camera,
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_controller!),
                  if (_markerCorners.isNotEmpty)
                    CustomPaint(
                      painter: BoundingBoxPainter(
                        corners: _markerCorners,
                        imageSize: Size(
                          _controller!.value.previewSize!.height,
                          _controller!.value.previewSize!.width,
                        ),
                        screenSize: MediaQuery.of(context).size,
                      ),
                    ),
                  
                  // HUD Overlay
                  Positioned(
                    bottom: AppSpacing.xl,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _detectedId != null ? AppColors.successGreen : Colors.white24,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _detectedId != null ? "Marker ID: $_detectedId" : "Searching for Marker...",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _distanceText,
                            style: TextStyle(
                              color: _detectedId != null ? AppColors.successGreen : Colors.white70,
                              fontSize: 32, 
                              fontWeight: FontWeight.w900
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<cv.Point2f> corners;
  final Size imageSize;
  final Size screenSize;

  BoundingBoxPainter({
    required this.corners,
    required this.imageSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;

    final paint = Paint()
      ..color = AppColors.successGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Scale coordinates from image space to screen space
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    final path = Path();
    path.moveTo(corners[0].x * scaleX, corners[0].y * scaleY);
    path.lineTo(corners[1].x * scaleX, corners[1].y * scaleY);
    path.lineTo(corners[2].x * scaleX, corners[2].y * scaleY);
    path.lineTo(corners[3].x * scaleX, corners[3].y * scaleY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return true;
  }
}
