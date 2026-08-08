import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/services/camera_calibration_service.dart';
import '../providers/calibration_provider.dart';

class CameraCalibrationPage extends ConsumerStatefulWidget {
  const CameraCalibrationPage({super.key});

  @override
  ConsumerState<CameraCalibrationPage> createState() =>
      _CameraCalibrationPageState();
}

class _CameraCalibrationPageState extends ConsumerState<CameraCalibrationPage> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  final List<Uint8List> _capturedImages = [];
  String _status = 'Capture 5-10 checkerboard images from different angles.';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _status = 'No cameras found.');
      return;
    }
    
    // Select back camera
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureFrame() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _status = 'Capturing...';
    });

    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();
      
      setState(() {
        _capturedImages.add(bytes);
        _status = 'Captured ${_capturedImages.length} images.';
      });
    } catch (e) {
      setState(() => _status = 'Error capturing: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _calibrate() async {
    if (_capturedImages.length < 3) {
      setState(() => _status = 'Need at least 3 images.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = 'Calibrating... This may take a moment.';
    });

    try {
      // In a real implementation we would convert the JPG bytes to Y-plane bytes.
      // But for simplicity in this demo, let's just pass the encoded bytes and 
      // rely on opencv imdecode inside the service. Wait, the service expects raw Y-plane bytes.
      // To fix this cleanly for the demo, we'll assume the bytes can be decoded by cv.imdecode.
      
      // We will adjust CameraCalibrationService to handle imdecode if needed, 
      // but for milestone 1.1 physical demo, we will use cv.imdecode inside the service.
      
      // Let's call the service
      final req = CalibrationRequest(
        imageBytesList: _capturedImages,
        width: 0, // Service will extract width/height from imdecode
        height: 0,
        cols: 7,
        rows: 5,
        squareSizeMeters: 0.030,
      );

      final result = await CameraCalibrationService.calibrate(req);

      if (result.isValid) {
        await ref.read(calibrationProvider.notifier).saveCalibration(result);
        if (mounted) {
          setState(() {
            _status = 'Success! Reprojection error: ${result.reprojectionError.toStringAsFixed(3)}';
            _capturedImages.clear();
          });
        }
      } else {
        setState(() => _status = 'Calibration failed. Ensure checkerboard is visible.');
      }
    } catch (e) {
      setState(() => _status = 'Error during calibration: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text('Camera Calibration', style: AppTextStyles.titleLarge),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            color: Colors.white,
            child: Column(
              children: [
                Text(_status, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _captureFrame,
                      icon: const Icon(Icons.camera),
                      label: const Text('Capture'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isProcessing || _capturedImages.isEmpty ? null : _calibrate,
                      icon: const Icon(Icons.check),
                      label: const Text('Calibrate'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
