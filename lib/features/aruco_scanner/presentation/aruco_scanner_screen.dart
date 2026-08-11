import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/navigation/navigation_header.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../vision/presentation/providers/aruco_vision_provider.dart';
import '../../vision/presentation/providers/alignment_provider.dart';
import '../../vision/presentation/providers/calibration_provider.dart';

class ArucoScannerScreen extends ConsumerStatefulWidget {
  const ArucoScannerScreen({super.key});

  @override
  ConsumerState<ArucoScannerScreen> createState() => _ArucoScannerScreenState();
}

class _ArucoScannerScreenState extends ConsumerState<ArucoScannerScreen> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
        imageFormatGroup: ImageFormatGroup.yuv420,
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

  void _processCameraFrame(CameraImage image) {
    if (image.planes.isEmpty) return;
    
    // We only need the Y plane (luminance) for OpenCV grayscale operations
    final plane = image.planes[0];
    
    ref.read(arucoVisionProvider.notifier).processFrame(
      yPlaneBytes: plane.bytes,
      width: image.width,
      height: image.height,
      rowStride: plane.bytesPerRow,
    );
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
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final visionState = ref.watch(arucoVisionProvider);
    final alignmentState = ref.watch(smoothedAlignmentProvider);
    // Read calibration state from the real provider — not by checking a status string.
    final isCalibrated = ref.watch(calibrationProvider).isValid;

    final markerCorners = visionState.detection?.corners ?? [];
    final detectedId = visionState.detection?.markerId;
    final pose = visionState.pose;
    
    String statusText = "Searching for Marker...";
    if (!isCalibrated) {
      statusText = "CAMERA NOT CALIBRATED";
    } else if (detectedId != null) {
      if (pose != null) {
        if (alignmentState.score > 90) {
          statusText = "ALIGNED & READY";
        } else {
          statusText = "Aligning...";
        }
      } else {
        statusText = "Calculating pose...";
      }
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
                  if (markerCorners.length == 4)
                    CustomPaint(
                      painter: BoundingBoxPainter(
                        corners: markerCorners,
                        imageSize: Size(
                          _controller!.value.previewSize!.height,
                          _controller!.value.previewSize!.width,
                        ),
                        screenSize: MediaQuery.of(context).size,
                      ),
                    ),
                  
                  // Top HUD
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${visionState.fps.toStringAsFixed(1)} FPS",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Developer Diagnostics Overlay
                  Positioned(
                    top: AppSpacing.md + 60,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black87.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("DEVELOPER DIAGNOSTICS", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("Camera: ${isCalibrated ? 'OK' : 'UNCALIBRATED'}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Frame: ${visionState.frameWidth}x${visionState.frameHeight}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Y Stride: ${visionState.rowStride}", style: const TextStyle(color: Colors.yellow, fontSize: 10)),
                          Text("OpenCV: ${visionState.debugError.isEmpty ? 'OK' : 'ERROR'}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          const Text("Dictionary: DICT_4X4_50", style: TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Detection FPS: ${visionState.fps.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("IDs: ${visionState.debugIds}", style: const TextStyle(color: Colors.greenAccent, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  
                  if (!isCalibrated)
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "UNCALIBRATED",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Bottom HUD Overlay
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
                          color: alignmentState.score > 90 
                              ? AppColors.successGreen 
                              : (detectedId != null ? AppColors.primary : Colors.white24),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            statusText,
                            style: TextStyle(
                              color: alignmentState.score > 90 
                                  ? AppColors.successGreen 
                                  : Colors.white, 
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (pose != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn("DIST", "${pose.distance.toStringAsFixed(2)}m"),
                                _buildStatColumn("YAW", "${pose.yaw.toStringAsFixed(1)}°"),
                                _buildStatColumn("ALIGN", "${alignmentState.score.toStringAsFixed(0)}%"),
                              ],
                            ),
                          ]
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<math.Point<double>> corners;
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
    final double scaleX = size.width / imageSize.height; 
    final double scaleY = size.height / imageSize.width;

    final path = Path();
    // Rotate coordinates for portrait mode (assuming phone is in portrait)
    path.moveTo(corners[0].y * scaleX, (imageSize.width - corners[0].x) * scaleY);
    path.lineTo(corners[1].y * scaleX, (imageSize.width - corners[1].x) * scaleY);
    path.lineTo(corners[2].y * scaleX, (imageSize.width - corners[2].x) * scaleY);
    path.lineTo(corners[3].y * scaleX, (imageSize.width - corners[3].x) * scaleY);
    path.close();

    canvas.drawPath(path, paint);
    
    // Draw 3D axis approximation (center dot for now)
    final centerX = (corners[0].y + corners[1].y + corners[2].y + corners[3].y) / 4 * scaleX;
    final centerY = (imageSize.width - (corners[0].x + corners[1].x + corners[2].x + corners[3].x) / 4) * scaleY;
    
    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 6.0, centerPaint);
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return true;
  }
}
