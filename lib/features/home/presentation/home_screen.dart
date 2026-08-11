import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/di_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../settings/presentation/providers/motion_library_provider.dart';
import '../../vision/presentation/providers/aruco_vision_provider.dart';
import '../../vision/domain/models/aruco_detection_result.dart';
import '../../vision/presentation/providers/alignment_provider.dart';
import '../../vision/domain/models/alignment_result.dart';
import '../../vision/presentation/providers/calibration_provider.dart';
import '../../connection/presentation/providers/connection_provider.dart';
import '../../manual_control/presentation/providers/manual_control_provider.dart';
import '../../../core/constants/vision_constants.dart';
import 'widgets/alignment_status_banner.dart';
import 'widgets/home_hud_overlay.dart';
import 'widgets/routine_selector_card.dart';
import '../../../shared/widgets/cards/surface_card.dart';
import '../../../shared/widgets/buttons/primary_action_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ─── Camera & Vision ─────────────────────────────────────────────────────
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        ref.read(arucoVisionProvider.notifier).setStatus('No Camera');
        return;
      }
      final rear = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        rear,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _cameraController!.initialize();
      if (mounted) {
        ref.read(arucoVisionProvider.notifier).setStatus('Live');
        setState(() {}); // Rebuild to show CameraPreview
        _cameraController!.startImageStream(_processFrame);
      }
    } catch (e) {
      debugPrint('HomeScreen camera error: $e');
      if (mounted) ref.read(arucoVisionProvider.notifier).setStatus('Error');
    }
  }

  void _processFrame(CameraImage image) {
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

  Future<void> _onStart() async {
    final library = ref.read(motionLibraryProvider);
    // Determine which routine to play
    final routines = library.routines;
    if (routines.isEmpty) return;
    final targetId = library.defaultRoutineId ?? routines.first.id;

    final repo = ref.read(robotRepositoryProvider);
    await repo.sendCommand('PLAY_ROUTINE', {'id': targetId});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(AppIcons.play, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Routine started',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
          ]),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final visionState = ref.watch(arucoVisionProvider);
    final alignmentState = ref.watch(alignmentProvider);
    // Explicitly check both unsafe states: no robot selected, and robot selected but not connected.
    // Note: in Dart, null?.status == 'Connected' would evaluate to false (null == 'Connected' is false),
    // but we make the null case explicit here to document intent, not rely on that implicit behavior.
    final activeRobot = ref.watch(connectionProvider).activeRobot;
    final isConnected = activeRobot != null && activeRobot.status == 'Connected';
    final isEStop = ref.watch(manualControlProvider).emergencyStopEngaged;
    final isCalibrated = ref.watch(calibrationProvider).isValid;
    final libraryState = ref.watch(motionLibraryProvider);
    
    // Check all required conditions for Start Cleaning
    final cameraAvailable = _cameraController?.value.isInitialized ?? false;
    final markerDetected = visionState.detection != null;
    final correctMarkerId = markerDetected && visionState.detection!.markerId == VisionConstants.targetMarkerId;
    final alignmentReady = alignmentState.status == AlignmentStatus.ready;
    final hasValidRoutine = libraryState.defaultRoutineId != null || libraryState.routines.isNotEmpty;

    final isReady = cameraAvailable &&
                    isCalibrated &&
                    markerDetected &&
                    correctMarkerId &&
                    alignmentReady &&
                    isConnected &&
                    !isEStop &&
                    hasValidRoutine;
                    
    final robotStatus = isConnected ? 'Connected' : 'Disconnected';

    final detectedId = visionState.detection?.markerId;
    final alignmentScore = alignmentState.score;
    
    // Uncalibrated or missing pose should show distance as unknown
    final bool distanceUnknown = alignmentState.status == AlignmentStatus.markerLost || 
                                 alignmentState.status == AlignmentStatus.error ||
                                 alignmentState.status == AlignmentStatus.scanning ||
                                 !isCalibrated;
                                 
    final distanceText = distanceUnknown 
      ? '—' 
      : '${alignmentState.distanceErrorM > 0 ? '+' : ''}${alignmentState.distanceErrorM.toStringAsFixed(2)}m';

    final allDetections = visionState.allDetections;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Row(
          children: [
            // ── LEFT PANEL: Camera (flex: 7) ────────────────────────────────────
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera preview or loading state
                    if (_cameraController != null &&
                        _cameraController!.value.isInitialized)
                      CameraPreview(_cameraController!)
                    else
                      _CameraLoadingView(status: visionState.status),

                    // Bounding box painter for ALL markers
                    if (allDetections.isNotEmpty)
                      CustomPaint(
                        painter: _MarkerPainter(
                          detections: allDetections,
                          activeMarkerId: detectedId,
                          activePoseDistance: distanceUnknown ? null : alignmentState.distanceErrorM,
                          activeAlignmentScore: alignmentScore,
                          imageSize: Size(
                            _cameraController!.value.previewSize!.height, // Assuming rotated sensor (width/height flipped)
                            _cameraController!.value.previewSize!.width,
                          ),
                        ),
                      ),

                    // HUD overlay
                    HomeHudOverlay(
                      markerId: detectedId,
                      semanticName: visionState.detection?.semanticName,
                      distanceText: distanceText,
                      alignmentScore: alignmentScore,
                      cameraStatus: isCalibrated ? visionState.status : 'Calibration Required',
                      robotStatus: robotStatus,
                      isEStop: isEStop,
                      isConnected: isConnected,
                    ),
                  ],
                ),
              ),
            ),

            // ── RIGHT PANEL: Action & Status (flex: 4) ─────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Row: Branding + Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/smartstall_logo.png',
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'SmartStall',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => context.go('/settings'),
                          icon: const Icon(AppIcons.settings, color: AppColors.text, size: 28),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.borderLight, width: 1.5),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Metric Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: SurfaceCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alignment', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  '${(alignmentScore * 100).toStringAsFixed(0)}%', 
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: alignmentScore >= 0.95 ? AppColors.successGreen : AppColors.text, 
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SurfaceCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Distance', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  distanceText, 
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.text, 
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Routine Selector & Alignment Banner wrapper
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AlignmentStatusBanner(
                            alignmentScore: alignmentScore,
                            hasMarker: detectedId != null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          RoutineSelectorCard(
                            isReady: isReady,
                            onStart: _onStart,
                            isConnected: isConnected,
                            isCalibrated: isCalibrated,
                            isEStop: isEStop,
                            markerDetected: markerDetected,
                            alignmentReady: alignmentReady,
                            cameraAvailable: cameraAvailable,
                          ),
                        ],
                      ),
                    ),
                    
                    // Primary Action Button anchored at bottom
                    PrimaryActionButton(
                      label: isReady ? 'START CLEANING' : 'NOT READY',
                      icon: isReady ? AppIcons.play : Icons.block,
                      onPressed: isReady ? _onStart : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ─── Camera Loading ───────────────────────────────────────────────────────────
class _CameraLoadingView extends StatelessWidget {
  final String status;
  const _CameraLoadingView({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              status,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Marker Bounding Box Painter ─────────────────────────────────────────────
class _MarkerPainter extends CustomPainter {
  final List<ArucoDetectionResult> detections;
  final int? activeMarkerId;
  final double? activePoseDistance;
  final double activeAlignmentScore;
  final Size imageSize;

  _MarkerPainter({
    required this.detections,
    required this.activeMarkerId,
    required this.activePoseDistance,
    required this.activeAlignmentScore,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;
    
    // Using the transposition mapping (y -> x, width - x -> y) which is common for portrait-native sensors in landscape mode.
    final scaleX = size.width / imageSize.height;
    final scaleY = size.height / imageSize.width;

    for (final detection in detections) {
      if (!detection.isValid) continue;
      
      final isActive = detection.markerId == activeMarkerId;
      final color = isActive ? AppColors.successGreen : Colors.orangeAccent;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 4.0 : 2.0;

      final corners = detection.corners;
      final path = Path()
        ..moveTo(corners[0].y * scaleX, (imageSize.width - corners[0].x) * scaleY)
        ..lineTo(corners[1].y * scaleX, (imageSize.width - corners[1].x) * scaleY)
        ..lineTo(corners[2].y * scaleX, (imageSize.width - corners[2].x) * scaleY)
        ..lineTo(corners[3].y * scaleX, (imageSize.width - corners[3].x) * scaleY)
        ..close();
      canvas.drawPath(path, paint);

      // Center dot
      final centerPaint = Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.fill;
      final cx = detection.center.y * scaleX;
      final cy = (imageSize.width - detection.center.x) * scaleY;
      canvas.drawCircle(Offset(cx, cy), isActive ? 6.0 : 4.0, centerPaint);

      // Label background
      final bgPaint = Paint()..color = Colors.black87;
      canvas.drawRect(Rect.fromLTWH(cx + 10, cy - 10, 150, isActive ? 50 : 25), bgPaint);

      // Text painter
      const textStyle = TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold);
      final span1 = TextSpan(text: 'ID: ${detection.markerId} (${detection.semanticName})', style: textStyle);
      final tp1 = TextPainter(text: span1, textDirection: TextDirection.ltr);
      tp1.layout();
      tp1.paint(canvas, Offset(cx + 14, cy - 6));

      if (isActive) {
        final distText = activePoseDistance != null ? '${(activePoseDistance!).toStringAsFixed(2)}m' : '—';
        final scoreText = '${(activeAlignmentScore * 100).toStringAsFixed(0)}%';
        final span2 = TextSpan(text: 'Dist: $distText | Align: $scoreText', style: textStyle.copyWith(color: AppColors.primary));
        final tp2 = TextPainter(text: span2, textDirection: TextDirection.ltr);
        tp2.layout();
        tp2.paint(canvas, Offset(cx + 14, cy + 8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter old) => true;
}
