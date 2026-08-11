import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/camera_calibration.dart';
import '../../domain/services/aruco_pose_service.dart';
import '../../domain/services/marker_registry.dart';
import '../../../settings/presentation/providers/global_settings_provider.dart';
import '../providers/calibration_provider.dart';

/// Landscape-optimised camera calibration page.
///
/// Uses the real camera + ArUco detection to perform a one-shot focal-length
/// calibration.  The operator places the ArUco marker at a known measured
/// distance and taps "Calibrate Now".
class CameraCalibrationPage extends ConsumerStatefulWidget {
  const CameraCalibrationPage({super.key});

  @override
  ConsumerState<CameraCalibrationPage> createState() =>
      _CameraCalibrationPageState();
}

class _CameraCalibrationPageState
    extends ConsumerState<CameraCalibrationPage> {
  CameraController? _cameraController;
  bool _isProcessing = false;

  // Live detection state
  double _livePixelWidth = 0.0;
  int? _liveMarkerId;
  int _frameWidth = 0;
  int _frameHeight = 0;

  // User input
  final _distanceController = TextEditingController(text: '50');

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

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
        setState(() {});
        _cameraController!.startImageStream(_processFrame);
      }
    } catch (e) {
      debugPrint('Calibration camera init error: $e');
    }
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final plane = image.planes[0];
      final request = ArucoPoseRequest(
        imageBytes: Uint8List.fromList(plane.bytes),
        width: image.width,
        height: image.height,
        rowStride: plane.bytesPerRow,
        defaultMarkerSizeMeters: ref.read(globalSettingsProvider).defaultMarkerSizeMeters,
        knownMarkerSizes: MarkerRegistry.knownMarkerSizes,
      );

      final response =
          await ArucoPoseService.detectAndEstimatePose(request);

      if (mounted) {
        setState(() {
          _frameWidth = image.width;
          _frameHeight = image.height;
          if (response.activeDetection != null) {
            _liveMarkerId = response.activeDetection!.markerId;
            // Compute pixel width from corners
            final c = response.activeDetection!.corners;
            final topEdge = _dist(c[0], c[1]);
            final bottomEdge = _dist(c[2], c[3]);
            _livePixelWidth = (topEdge + bottomEdge) / 2.0;
          } else {
            _liveMarkerId = null;
            _livePixelWidth = 0.0;
          }
        });
      }
    } catch (_) {
      // Ignore transient errors
    } finally {
      _isProcessing = false;
    }
  }

  double _dist(dynamic a, dynamic b) {
    final dx = (a.x - b.x) as double;
    final dy = (a.y - b.y) as double;
    return (dx * dx + dy * dy).abs().toDouble();
  }

  void _calibrateNow() {
    if (_liveMarkerId == null || _livePixelWidth < 20) return;

    final knownDistanceCm =
        double.tryParse(_distanceController.text) ?? 50.0;
    final knownDistanceM = knownDistanceCm / 100.0;

    final globalSize = ref.read(globalSettingsProvider).defaultMarkerSizeMeters;
    final markerRealSizeM = MarkerRegistry.knownMarkerSizes[_liveMarkerId] ?? globalSize;

    // focal_length_px = (pixel_width × known_distance) / marker_real_size
    final focalLength =
        (_livePixelWidth * knownDistanceM) / markerRealSizeM;

    final calib = CameraCalibration(
      focalLengthPx: focalLength,
      markerPixelWidth: _livePixelWidth,
      calibrationDistanceM: knownDistanceM,
      markerSizeM: markerRealSizeM,
      imageWidth: _frameWidth,
      imageHeight: _frameHeight,
      isValid: true,
      timestamp: DateTime.now().toIso8601String(),
    );

    ref.read(calibrationProvider.notifier).saveCalibration(calib);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Calibration saved  ·  fx = ${focalLength.toStringAsFixed(1)} px',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
      ),
    );
  }

  void _clearCalibration() {
    ref.read(calibrationProvider.notifier).clearCalibration();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Calibration cleared',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.warningOrange,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentCalib = ref.watch(calibrationProvider);
    final markerDetected = _liveMarkerId != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Camera Calibration',
          style:
              AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Row(
          children: [
            // ── LEFT: Camera Preview (60%) ─────────────────────────────────
            Expanded(
              flex: 60,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_cameraController != null &&
                          _cameraController!.value.isInitialized)
                        CameraPreview(_cameraController!)
                      else
                        Container(
                          color: Colors.black,
                          child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary)),
                        ),

                      // Live marker info overlay
                      Positioned(
                        bottom: AppSpacing.md,
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: markerDetected
                                  ? AppColors.successGreen.withOpacity(0.5)
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _OverlayMetric(
                                label: 'MARKER',
                                value: markerDetected
                                    ? '#$_liveMarkerId'
                                    : 'Not Found',
                                color: markerDetected
                                    ? AppColors.successGreen
                                    : AppColors.warningOrange,
                              ),
                              Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.white12),
                              _OverlayMetric(
                                label: 'PIXEL WIDTH',
                                value: markerDetected
                                    ? _livePixelWidth.toStringAsFixed(1)
                                    : '—',
                                color: Colors.white,
                              ),
                              Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.white12),
                              _OverlayMetric(
                                label: 'FRAME',
                                value: '$_frameWidth x $_frameHeight',
                                color: Colors.white54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── RIGHT: Controls (40%) ──────────────────────────────────────
            Expanded(
              flex: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current calibration status
                      _StatusCard(calibration: currentCalib),
                      const SizedBox(height: AppSpacing.lg),

                      // Known distance input
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.borderLight, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Known Distance',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _distanceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      hintText: '50',
                                      suffixText: 'cm',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.borderLight),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.primary,
                                            width: 2),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.lg,
                                              vertical: AppSpacing.md),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Place the ArUco marker at this exact distance from the camera.',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Calibrate button
                      ElevatedButton.icon(
                        onPressed: markerDetected ? _calibrateNow : null,
                        icon: Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: markerDetected
                              ? Colors.white
                              : Colors.black38,
                        ),
                        label: Text(
                          markerDetected
                              ? 'Calibrate Now'
                              : 'Point Camera at Marker',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: markerDetected
                                ? Colors.white
                                : Colors.black38,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: markerDetected
                              ? AppColors.primary
                              : AppColors.borderLight,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Clear button
                      if (currentCalib.isValid)
                        OutlinedButton.icon(
                          onPressed: _clearCalibration,
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.dangerRed),
                          label: Text(
                            'Clear Calibration',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.dangerRed),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.dangerRed, width: 1.5),
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md),
                            shape: const StadiumBorder(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _OverlayMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _OverlayMetric(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white38, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.bodyLarge
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final CameraCalibration calibration;
  const _StatusCard({required this.calibration});

  @override
  Widget build(BuildContext context) {
    final valid = calibration.isValid;
    final statusColor = valid ? AppColors.successGreen : AppColors.warningOrange;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                valid
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                valid ? 'Calibrated' : 'Not Calibrated',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (valid) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
                'Focal Length', '${calibration.focalLengthPx.toStringAsFixed(1)} px'),
            _DetailRow(
                'Calibration Distance',
                '${(calibration.calibrationDistanceM * 100).toStringAsFixed(0)} cm'),
            _DetailRow('Resolution',
                '${calibration.imageWidth}×${calibration.imageHeight}'),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
