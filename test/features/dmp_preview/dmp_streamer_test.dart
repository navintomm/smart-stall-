import 'package:flutter_test/flutter_test.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/models/dmp_result.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/models/dmp_trajectory_sample.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/models/trajectory_streaming_state.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/services/dmp_trajectory_streamer.dart';
import 'package:smartstall_operator/core/repositories/robot_repository.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/models/dmp_joint_metrics.dart';

class MockRobotRepository implements RobotRepository {
  List<Map<String, dynamic>> commands = [];

  @override
  Future<void> sendCommand(String command, [Map<String, dynamic>? payload]) async {
    commands.add({'command': command, 'payload': payload});
  }

  @override Future<void> moveServo(String servoId, int angle) async {}
  @override Future<void> pauseCleaning() async {}
  @override Future<void> resumeCleaning() async {}
  @override Future<void> startCleaning() async {}
  @override Future<void> startCleaningWithProfile(dynamic profile) async {}
  @override Future<void> stopCleaning() async {}
  @override Future<void> toggleTool(String toolId, bool state) async {}
  @override Future<void> triggerEmergencyStop() async {}
}

void main() {
  group('DmpTrajectoryStreamer', () {
    late MockRobotRepository repo;
    late DmpTrajectoryStreamer streamer;

    setUp(() {
      repo = MockRobotRepository();
      streamer = DmpTrajectoryStreamer(repo);
    });

    test('starts streaming and sends BEGIN and first chunks', () async {
      final samples = List.generate(
        30,
        (i) => DmpTrajectorySample(
          timeSeconds: i * 0.1,
          servo1Angle: i.toDouble(),
          servo2Angle: i.toDouble(),
        ),
      );

      final result = DmpResult(
        routineId: 'test',
        routineName: 'test',
        durationSeconds: 3.0,
        originalSamples: [],
        generatedSamples: samples,
        servo1Metrics: const DmpJointMetrics(jointName: 's1', mae: 0, rmse: 0, maxError: 0, smoothnessOriginal: 0, smoothnessGenerated: 0),
        servo2Metrics: const DmpJointMetrics(jointName: 's2', mae: 0, rmse: 0, maxError: 0, smoothnessOriginal: 0, smoothnessGenerated: 0),
        startPositionPreserved: true,
        goalPositionPreserved: true,
        noNanValues: true,
        noInfiniteValues: true,
      );

      await streamer.startStreaming(result);

      // Verify BEGIN was sent
      expect(repo.commands[0]['command'], 'TRAJECTORY_CONTROL');
      expect(repo.commands[0]['payload']['action'], 'BEGIN');

      // Verify at least the first two chunks were sent (because 30 samples = 2 chunks)
      expect(repo.commands.length, greaterThanOrEqualTo(3)); // BEGIN, chunk0, chunk1
      
      expect(repo.commands[1]['command'], 'TRAJECTORY_CHUNK');
      expect(repo.commands[2]['command'], 'TRAJECTORY_CHUNK');
      
      final state = streamer.state;
      expect(state.status, StreamingStatus.streaming);
      expect(state.totalChunks, 2); // 30 samples / 20 = 2 chunks
    });
  });
}
