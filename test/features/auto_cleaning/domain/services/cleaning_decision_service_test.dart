import 'package:flutter_test/flutter_test.dart';
import 'package:smartstall_operator/features/vision/domain/models/dirt_severity.dart';
import 'package:smartstall_operator/features/vision/domain/models/dirt_detection_result.dart';
import 'package:smartstall_operator/features/auto_cleaning/domain/services/cleaning_decision_service.dart';

void main() {
  group('CleaningDecisionService', () {
    late CleaningDecisionService service;

    setUp(() {
      service = CleaningDecisionService();
    });

    test('Clean severity returns minimum dosage', () {
      final result = DirtDetectionResult(
        detected: false,
        confidence: 0.9,
        severity: DirtSeverity.clean,
        affectedArea: 0.0,
        timestamp: DateTime.now(),
        modelVersion: 'test',
      );

      final profile = service.generateRecommendation(result);
      
      // When detected is false, it returns safe default
      expect(profile.severity, DirtSeverity.clean);
      expect(profile.waterVolumeMl, 0);
      expect(profile.pumpDurationMs, 0);
    });

    test('Light severity returns light profile', () {
      final result = DirtDetectionResult(
        detected: true,
        confidence: 0.9,
        severity: DirtSeverity.light,
        affectedArea: 0.1,
        timestamp: DateTime.now(),
        modelVersion: 'test',
      );

      final profile = service.generateRecommendation(result);
      
      expect(profile.severity, DirtSeverity.light);
      expect(profile.waterVolumeMl, 150);
      // 150 / 70 = 2.14 seconds = 2142 ms
      expect(profile.pumpDurationMs, 2142); 
    });

    test('Moderate severity returns standard profile', () {
      final result = DirtDetectionResult(
        detected: true,
        confidence: 0.8,
        severity: DirtSeverity.moderate,
        affectedArea: 0.4,
        timestamp: DateTime.now(),
        modelVersion: 'test',
      );

      final profile = service.generateRecommendation(result);
      
      expect(profile.severity, DirtSeverity.moderate);
      expect(profile.waterVolumeMl, 300);
      // 300 / 70 = 4.28 seconds = 4285 ms
      expect(profile.pumpDurationMs, 4285);
    });

    test('Heavy severity returns heavy profile', () {
      final result = DirtDetectionResult(
        detected: true,
        confidence: 0.7,
        severity: DirtSeverity.heavy,
        affectedArea: 0.6,
        timestamp: DateTime.now(),
        modelVersion: 'test',
      );

      final profile = service.generateRecommendation(result);
      
      expect(profile.severity, DirtSeverity.heavy);
      expect(profile.waterVolumeMl, 500);
      // 500 / 70 = 7.14 seconds = 7142 ms
      expect(profile.pumpDurationMs, 7142);
    });

    test('Severe severity returns intensive profile', () {
      final result = DirtDetectionResult(
        detected: true,
        confidence: 0.95,
        severity: DirtSeverity.severe,
        affectedArea: 0.9,
        timestamp: DateTime.now(),
        modelVersion: 'test',
      );

      final profile = service.generateRecommendation(result);
      
      expect(profile.severity, DirtSeverity.severe);
      expect(profile.waterVolumeMl, 800);
      // 800 / 70 = 11.42 seconds = 11428 ms
      expect(profile.pumpDurationMs, 11428);
    });

    test('Safe default generated when undetected', () {
      final result = DirtDetectionResult.empty();
      final profile = service.generateRecommendation(result);
      expect(profile.waterVolumeMl, 0);
      expect(profile.pumpDurationMs, 0);
    });
  });
}
