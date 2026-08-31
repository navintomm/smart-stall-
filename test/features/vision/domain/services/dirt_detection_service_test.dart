import 'package:flutter_test/flutter_test.dart';
import 'package:smartstall_operator/features/vision/domain/services/dirt_detection_service.dart';
import 'package:smartstall_operator/features/vision/domain/services/mock_dirt_detection_model.dart';
import 'package:camera/camera.dart';

class FakeCameraImage implements CameraImage {
  @override
  int get width => 640;
  @override
  int get height => 480;
  @override
  ImageFormat get format => ImageFormatGroup.yuv420 as dynamic;
  @override
  List<Plane> get planes => [];
  @override
  double? get lensAperture => null;
  @override
  int? get sensorExposureTime => null;
  @override
  double? get sensorSensitivity => null;
}

void main() {
  group('DirtDetectionService and Mock Model', () {
    late DirtDetectionService service;
    late MockDirtDetectionModel mockModel;

    setUp(() {
      mockModel = MockDirtDetectionModel();
      service = DirtDetectionService(mockModel);
    });

    test('Mock model initialization works', () async {
      await mockModel.initialize();
      final dummyFrame = FakeCameraImage();
      final result = await mockModel.detect(dummyFrame);
      expect(result.modelVersion, 'MOCK-v0.1-DEV');
      expect(result.isSimulation, true);
    });

    test('Service processFrame handles uninitialized state gracefully', () async {
      final dummyFrame = FakeCameraImage();
      final result = await service.processFrame(dummyFrame);
      expect(result, isNotNull);
      expect(result!.modelVersion, 'MOCK-v0.1-DEV');
    });

    test('Dispose releases model resources', () async {
      await service.initialize();
      await service.dispose();
      
      final dummyFrame = FakeCameraImage();
      final result = await service.processFrame(dummyFrame);
      expect(result, isNotNull);
    });
  });
}
