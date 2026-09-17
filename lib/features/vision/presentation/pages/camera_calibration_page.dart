import 'dart:math' as math;
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
  bool _isScanning = true;

  // Live detection state
  double _livePixelWidth = 0.0;
  int? _liveMarkerId;
  int _frameWidth = 0;
  int _frameHeight = 0;
  double _liveDistanceCm = 0.0;
  double _liveAngleDeg = 0.0;
  List<_DetectedMarkerInfo> _allDetectedMarkers = [];

  // User input
  final _distanceController = TextEditingController(text: '30');
  final _markerSizeController = TextEditingController(text: '8.5');

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
        _startStream();
      }
    } catch (e) {
      debugPrint('Calibration camera init error: $e');
    }
  }

  void _startStream() {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraController!.value.isStreamingImages) {
      _cameraController!.startImageStream(_processFrame);
    }
  }

  void _stopStream() {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _startStream();
      } else {
        _stopStream();
      }
    });
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing || !_isScanning) return;
    _isProcessing = true;

    try {
      final plane = image.planes[0];
      final markerSizeCm =
          double.tryParse(_markerSizeController.text) ?? 8.5;
      final markerSizeM = markerSizeCm / 100.0;

      final request = ArucoPoseRequest(
        imageBytes: Uint8List.fromList(plane.bytes),
        width: image.width,
        height: image.height,
        rowStride: plane.bytesPerRow,
        defaultMarkerSizeMeters: markerSizeM,
        knownMarkerSizes: MarkerRegistry.knownMarkerSizes,
      );

      final response =
          await ArucoPoseService.detectAndEstimatePose(request);

      if (mounted) {
        setState(() {
          _frameWidth = image.width;
          _frameHeight = image.height;

          // Build list of all detected markers
          _allDetectedMarkers = response.allDetections.map((det) {
            double distCm = 0.0;
            if (response.activePose != null &&
                det.markerId == response.activeDetection?.markerId) {
              distCm = response.activePose!.z * 100.0;
            }
            return _DetectedMarkerInfo(
              id: det.markerId,
              distanceCm: distCm,
              angleDeg: det.rotationDeg,
              pixelWidth: det.pixelWidth,
            );
          }).toList();

          if (response.activeDetection != null) {
            _liveMarkerId = response.activeDetection!.markerId;
            final c = response.activeDetection!.corners;
            final topEdge = _dist(c[0], c[1]);
            final bottomEdge = _dist(c[2], c[3]);
            _livePixelWidth = (topEdge + bottomEdge) / 2.0;
            _liveAngleDeg = response.activeDetection!.rotationDeg;
            if (response.activePose != null) {
              _liveDistanceCm = response.activePose!.z * 100.0;
            } else {
              // Fallback: simple pinhole model
              final currentCalib = ref.read(calibrationProvider);
              if (currentCalib.isValid && _livePixelWidth > 0) {
                _liveDistanceCm =
                    (markerSizeM * currentCalib.focalLengthPx) /
                        _livePixelWidth *
                        100.0;
              }
            }
          } else {
            _liveMarkerId = null;
            _livePixelWidth = 0.0;
            _liveDistanceCm = 0.0;
            _liveAngleDeg = 0.0;
          }
        });
      }
    } catch (e) {
      debugPrint('Frame processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  double _dist(dynamic a, dynamic b) {
    final dx = (a.x - b.x) as double;
    final dy = (a.y - b.y) as double;
    return math.sqrt(dx * dx + dy * dy);
  }

  void _calibrateNow() {
    if (_liveMarkerId == null || _livePixelWidth < 20) return;

    final knownDistanceCm =
        double.tryParse(_distanceController.text) ?? 30.0;
    final knownDistanceM = knownDistanceCm / 100.0;

    final markerSizeCm =
        double.tryParse(_markerSizeController.text) ?? 8.5;
    final markerRealSizeM = markerSizeCm / 100.0;

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

    // Also update the global marker size setting
    ref
        .read(globalSettingsProvider.notifier)
        .setDefaultMarkerSize(markerRealSizeM);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Calibrated! fx=${focalLength.toStringAsFixed(1)}px | Marker=${markerSizeCm}cm | Dist=${knownDistanceCm}cm',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
  }

  void _clearCalibration() {
    ref.read(calibrationProvider.notifier).clearCalibration();
    if (mounted) {
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
  }

  @override
  void dispose() {
    _stopStream();
    _cameraController?.dispose();
    _distanceController.dispose();
    _markerSizeController.dispose();
    super.dispose();
  }

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ArUco Calibration',
              style:
                  AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            // Status badges
            if (_isScanning)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Scanning',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: currentCalib.isValid
                    ? Colors.green.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentCalib.isValid
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    size: 12,
                    color: currentCalib.isValid
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentCalib.isValid ? 'Calibrated' : 'Uncalibrated',
                    style: TextStyle(
                      color: currentCalib.isValid
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Row(
          children: [
            // LEFT: Camera Preview (60%)
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

                      // Live overlay with marker info
                      if (markerDetected)
                        Positioned(
                          top: AppSpacing.md,
                          left: AppSpacing.md,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ID:$_liveMarkerId | ${_liveDistanceCm.toStringAsFixed(1)} cm | ${_liveAngleDeg.toStringAsFixed(0)}°',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Bottom stats bar
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
                                    : 'None',
                                color: markerDetected
                                    ? AppColors.successGreen
                                    : AppColors.warningOrange,
                              ),
                              Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.white12),
                              _OverlayMetric(
                                label: 'PIXEL W',
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
                                value: '$_frameWidth×$_frameHeight',
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

            // RIGHT: Controls (40%)
            Expanded(
              flex: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Scan toggle button
                      ElevatedButton.icon(
                        onPressed: _toggleScanning,
                        icon: Icon(
                          _isScanning
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isScanning ? 'Stop Scan' : 'Start Scan',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isScanning
                              ? AppColors.dangerRed
                              : AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Marker Size Input ──
                      _InputField(
                        label: 'Real Marker Size (cm):',
                        hint: 'Place marker at this distance',
                        controller: _markerSizeController,
                        suffixText: 'cm',
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Calibration Distance Input ──
                      _InputField(
                        label: 'Calibration Distance (cm):',
                        hint: 'Place marker at this distance',
                        controller: _distanceController,
                        suffixText: 'cm',
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Calibrate + Clear buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  markerDetected ? _calibrateNow : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: markerDetected
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                shape: const StadiumBorder(),
                                elevation: 0,
                              ),
                              child: Text(
                                'Calibrate',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: markerDetected
                                      ? Colors.white
                                      : Colors.black38,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: currentCalib.isValid
                                  ? _clearCalibration
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: currentCalib.isValid
                                        ? AppColors.dangerRed
                                        : AppColors.borderLight,
                                    width: 1.5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(
                                'Clear',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: currentCalib.isValid
                                      ? AppColors.dangerRed
                                      : Colors.black38,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Detected Markers List ──
                      Text(
                        'Detected Markers (${_allDetectedMarkers.length})',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_allDetectedMarkers.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.borderLight, width: 1),
                          ),
                          child: const Center(
                            child: Text(
                              'No markers detected',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ...(_allDetectedMarkers.map((m) => Container(
                              margin:
                                  const EdgeInsets.only(bottom: AppSpacing.xs),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.borderLight, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Marker #${m.id}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Dist: ${m.distanceCm.toStringAsFixed(1)} cm',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Ang: ${m.angleDeg.toStringAsFixed(0)}°',
                                    style: TextStyle(
                                      color: Colors.cyan.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ))),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Calibration Info ──
                      if (currentCalib.isValid) ...[
                        _StatusCard(calibration: currentCalib),
                      ],
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

// ─── Helper Models ───────────────────────────────────────────────────────────

class _DetectedMarkerInfo {
  final int id;
  final double distanceCm;
  final double angleDeg;
  final double pixelWidth;

  _DetectedMarkerInfo({
    required this.id,
    required this.distanceCm,
    required this.angleDeg,
    required this.pixelWidth,
  });
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String suffixText;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 11),
              suffixText: suffixText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.successGreen.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.successGreen, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Calibration Info',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow('Focal Length',
              '${calibration.focalLengthPx.toStringAsFixed(1)} px'),
          _DetailRow(
              'Calibration Distance',
              '${(calibration.calibrationDistanceM * 100).toStringAsFixed(0)} cm'),
          _DetailRow('Marker Size',
              '${(calibration.markerSizeM * 100).toStringAsFixed(1)} cm'),
          _DetailRow('Resolution',
              '${calibration.imageWidth}×${calibration.imageHeight}'),
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
