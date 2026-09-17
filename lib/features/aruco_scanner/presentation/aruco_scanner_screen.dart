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
                        imageWidth: visionState.frameWidth.toDouble(),
                        imageHeight: visionState.frameHeight.toDouble(),
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
                          Text("Marker Detected: ${detectedId != null ? 'YES' : 'NO'}", style: TextStyle(color: detectedId != null ? Colors.green : Colors.red, fontSize: 10)),
                          Text("Marker ID: ${detectedId ?? '--'}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Camera: ${isCalibrated ? 'OK' : 'UNCALIBRATED'}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Resolution: ${visionState.frameWidth}x${visionState.frameHeight}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Processing FPS: ${visionState.fps.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Pose FPS: ${visionState.fps.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Worker Status: ${visionState.grayscaleConversionStatus}", style: const TextStyle(color: Colors.yellow, fontSize: 10)),
                          Text("Marker Size: ${pose != null ? 'Configured' : '--'}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text("Tx: ${pose?.x.toStringAsFixed(3) ?? '--'} m", style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 10)),
                          Text("Ty: ${pose?.y.toStringAsFixed(3) ?? '--'} m", style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 10)),
                          Text("Tz: ${pose?.z.toStringAsFixed(3) ?? '--'} m", style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 10)),
                          Text("Distance: ${pose?.distance.toStringAsFixed(3) ?? '--'} m", style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text("Roll: ${pose?.roll.toStringAsFixed(1) ?? '--'}°", style: const TextStyle(color: Colors.orangeAccent, fontSize: 10)),
                          Text("Pitch: ${pose?.pitch.toStringAsFixed(1) ?? '--'}°", style: const TextStyle(color: Colors.orangeAccent, fontSize: 10)),
                          Text("Yaw: ${pose?.yaw.toStringAsFixed(1) ?? '--'}°", style: const TextStyle(color: Colors.orangeAccent, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text("Last Pose: ${visionState.lastDetectionTimestamp?.toLocal().toString().split('.')[0] ?? '--'}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text("Error: ${visionState.debugError.isEmpty ? '--' : visionState.debugError}", style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
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
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter({
    required this.corners,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;

    final paint = Paint()
      ..color = AppColors.successGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // The camera image comes from the Y-plane which is (width x height) from
    // the sensor.  On a landscape Android device the sensor width maps to the
    // screen width and the sensor height maps to the screen height.
    final double scaleX = size.width / imageWidth;
    final double scaleY = size.height / imageHeight;

    Offset mapPoint(math.Point<double> p) =>
        Offset(p.x * scaleX, p.y * scaleY);

    final path = Path();
    path.moveTo(mapPoint(corners[0]).dx, mapPoint(corners[0]).dy);
    path.lineTo(mapPoint(corners[1]).dx, mapPoint(corners[1]).dy);
    path.lineTo(mapPoint(corners[2]).dx, mapPoint(corners[2]).dy);
    path.lineTo(mapPoint(corners[3]).dx, mapPoint(corners[3]).dy);
    path.close();

    canvas.drawPath(path, paint);

    // Draw center dot
    final cx = (corners[0].x + corners[1].x + corners[2].x + corners[3].x) / 4;
    final cy = (corners[0].y + corners[1].y + corners[2].y + corners[3].y) / 4;
    final center = Offset(cx * scaleX, cy * scaleY);

    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6.0, centerPaint);
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return true;
  }
}
