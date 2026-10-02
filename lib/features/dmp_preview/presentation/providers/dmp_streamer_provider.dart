import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../domain/models/trajectory_streaming_state.dart';
import '../../domain/services/dmp_trajectory_streamer.dart';

final dmpStreamerProvider = StateNotifierProvider.autoDispose<DmpTrajectoryStreamer, TrajectoryStreamingState>((ref) {
  final robotRepo = ref.watch(robotRepositoryProvider);
  return DmpTrajectoryStreamer(robotRepo);
});
