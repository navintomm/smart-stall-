import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../core/providers/di_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../settings/presentation/providers/motion_library_provider.dart';
import '../../vision/presentation/providers/aruco_vision_provider.dart';
import '../../vision/presentation/providers/alignment_provider.dart';
import '../../vision/domain/models/alignment_result.dart';
import 'widgets/alignment_status_banner.dart';
import 'widgets/home_hud_overlay.dart';
import 'widgets/routine_selector_card.dart';

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
            const Icon(AppIcons.play, color: Colors.black, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Routine started',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.black),
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
    
    final isReady = alignmentState.status == AlignmentStatus.ready;
    const robotStatus = 'Standby'; // Would read from robot telemetry provider

    final detectedId = visionState.detection?.markerId;
    final alignmentScore = alignmentState.score;
    final distanceText = alignmentState.status == AlignmentStatus.markerLost || alignmentState.status == AlignmentStatus.error 
      ? '—' 
      : '${alignmentState.distanceErrorM > 0 ? '+' : ''}${alignmentState.distanceErrorM.toStringAsFixed(2)}m';

    final markerCorners = visionState.detection?.corners ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────────────────
            _HomeAppBar(cameraStatus: visionState.status, robotStatus: robotStatus),

            // ── Camera + HUD (fills most of screen) ──────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera preview or loading state
                  if (_cameraController != null &&
                      _cameraController!.value.isInitialized)
                    CameraPreview(_cameraController!)
                  else
                    _CameraLoadingView(status: visionState.status),

                  // Bounding box painter
                  if (markerCorners.length == 4)
                    CustomPaint(
                      painter: _MarkerPainter(
                        corners: markerCorners,
                        imageSize: Size(
                          _cameraController!.value.previewSize!.height,
                          _cameraController!.value.previewSize!.width,
                        ),
                      ),
                    ),

                  // HUD overlay
                  HomeHudOverlay(
                    markerId: detectedId,
                    distanceText: distanceText,
                    alignmentScore: alignmentScore,
                    cameraStatus: visionState.status,
                    robotStatus: robotStatus,
                  ),
                ],
              ),
            ),

            // ── Bottom Panel (white surface) ──────────────────────────────
            _BottomPanel(
              alignmentScore: alignmentScore,
              hasMarker: detectedId != null,
              isReady: isReady,
              onStart: _onStart,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  final String cameraStatus;
  final String robotStatus;
  const _HomeAppBar(
      {required this.cameraStatus, required this.robotStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Image.asset(
            'assets/images/smartstall_logo.png',
            width: 40,
            height: 40,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartStall',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                Text(
                  'Operator Home',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.dangerRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.dangerRed.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.dangerRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.dangerRed,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Panel ─────────────────────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  final double alignmentScore;
  final bool hasMarker;
  final bool isReady;
  final VoidCallback onStart;

  const _BottomPanel({
    required this.alignmentScore,
    required this.hasMarker,
    required this.isReady,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Banner centred
          Center(
            child: AlignmentStatusBanner(
              alignmentScore: alignmentScore,
              hasMarker: hasMarker,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Routine Selector + Start Button
          RoutineSelectorCard(
            isReady: isReady,
            onStart: onStart,
          ),
        ],
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
  final List<math.Point<double>> corners;
  final Size imageSize;

  _MarkerPainter({required this.corners, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;
    final paint = Paint()
      ..color = AppColors.successGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;
    final path = Path()
      ..moveTo(corners[0].x * scaleX, corners[0].y * scaleY)
      ..lineTo(corners[1].x * scaleX, corners[1].y * scaleY)
      ..lineTo(corners[2].x * scaleX, corners[2].y * scaleY)
      ..lineTo(corners[3].x * scaleX, corners[3].y * scaleY)
      ..close();
    canvas.drawPath(path, paint);

    // Corner dots
    final dotPaint = Paint()
      ..color = AppColors.successGreen
      ..style = PaintingStyle.fill;
    for (final c in corners) {
      canvas.drawCircle(
          Offset(c.x * scaleX, c.y * scaleY), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter old) => true;
}
