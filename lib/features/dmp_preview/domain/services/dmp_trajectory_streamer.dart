import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/repositories/robot_repository.dart';
import '../models/dmp_result.dart';
import '../models/trajectory_chunk.dart';
import '../models/trajectory_streaming_state.dart';
import 'trajectory_chunker.dart';

class DmpTrajectoryStreamer extends StateNotifier<TrajectoryStreamingState> {
  final RobotRepository _robotRepository;
  
  List<TrajectoryChunk> _chunks = [];
  Timer? _scheduleTimer;
  int _nextChunkToSend = 0;
  DateTime? _streamingStartTime;

  DmpTrajectoryStreamer(this._robotRepository) : super(const TrajectoryStreamingState());

  /// Starts the streaming process for a trajectory
  Future<void> startStreaming(DmpResult result) async {
    if (state.status == StreamingStatus.streaming || state.status == StreamingStatus.preparing) {
      return; // Already streaming
    }

    state = const TrajectoryStreamingState(status: StreamingStatus.preparing);

    try {
      _chunks = TrajectoryChunker.chunkTrajectory(result.generatedSamples);
      
      if (_chunks.isEmpty) {
        throw Exception("Trajectory has no samples to stream.");
      }

      final totalSamples = result.generatedSamples.length;
      final trajectoryId = 'DMP_${DateTime.now().millisecondsSinceEpoch}';

      state = state.copyWith(
        status: StreamingStatus.sendingBegin,
        totalChunks: _chunks.length,
        totalSamples: totalSamples,
        trajectoryId: trajectoryId,
      );

      // Send BEGIN
      await _robotRepository.sendCommand('TRAJECTORY_CONTROL', {
        'action': 'BEGIN',
        'trajectory_id': trajectoryId,
      });

      state = state.copyWith(status: StreamingStatus.streaming);
      _nextChunkToSend = 0;
      _streamingStartTime = DateTime.now();

      _scheduleNextChunks();
    } catch (e) {
      state = state.copyWith(
        status: StreamingStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Sends the next chunks while maintaining buffer safety without blocking delays.
  /// ESP32 buffer is 50 samples. Each chunk is 20. We can safely keep 2 chunks in flight.
  void _scheduleNextChunks() {
    if (state.status != StreamingStatus.streaming) return;

    if (_nextChunkToSend >= _chunks.length) {
      _finishStreaming();
      return;
    }

    // If we are just starting, send the first two chunks immediately to fill the buffer.
    if (_nextChunkToSend == 0) {
      _sendChunkUnsafe(_chunks[0]);
      if (_chunks.length > 1) {
        _sendChunkUnsafe(_chunks[1]);
      }
      _scheduleNextChunks();
      return;
    }

    // For subsequent chunks, we schedule them to be sent when the execution of 
    // previously sent chunks frees up space in the 50-sample buffer.
    // Chunk `i` can be safely sent when Chunk `i-2` has completed execution.
    if (_nextChunkToSend >= 2) {
      final chunkToWaitFor = _chunks[_nextChunkToSend - 2];
      
      // Calculate when chunk `i-2` will finish executing
      final chunkFinishTimeSec = chunkToWaitFor.samples.last.timeSeconds;
      
      // Time elapsed since we started streaming
      final elapsedSec = DateTime.now().difference(_streamingStartTime!).inMilliseconds / 1000.0;
      
      // Calculate how long we must wait. We add a tiny buffer (50ms) to ensure we don't underflow.
      // But we must stay ahead of the execution.
      final delaySec = chunkFinishTimeSec - elapsedSec - 0.05; 

      if (delaySec > 0) {
        _scheduleTimer?.cancel();
        _scheduleTimer = Timer(Duration(milliseconds: (delaySec * 1000).toInt()), () {
          if (state.status != StreamingStatus.streaming) return;
          _sendChunkUnsafe(_chunks[_nextChunkToSend]);
          _scheduleNextChunks();
        });
      } else {
        // We are behind schedule (or execution is fast), send immediately
        _sendChunkUnsafe(_chunks[_nextChunkToSend]);
        _scheduleNextChunks();
      }
    }
  }

  Future<void> _sendChunkUnsafe(TrajectoryChunk chunk) async {
    try {
      await _robotRepository.sendCommand('TRAJECTORY_CHUNK', {
        'samples': chunk.toJsonPayload(),
      });
      
      _nextChunkToSend++;
      
      state = state.copyWith(
        currentChunk: _nextChunkToSend,
        samplesTransmitted: state.samplesTransmitted + chunk.samples.length,
      );
    } catch (e) {
      _scheduleTimer?.cancel();
      state = state.copyWith(
        status: StreamingStatus.failed,
        error: "Failed sending chunk ${chunk.chunkIndex}: $e",
      );
      abortStreaming();
    }
  }

  Future<void> _finishStreaming() async {
    _scheduleTimer?.cancel();
    state = state.copyWith(status: StreamingStatus.sendingEnd);

    try {
      await _robotRepository.sendCommand('TRAJECTORY_CONTROL', {
        'action': 'END',
      });
      state = state.copyWith(status: StreamingStatus.ready);
      
      // Mark as completed after a slight delay to allow execution to finish on hardware
      // The actual execution might take a few seconds. For UI purposes we mark it ready.
      Future.delayed(const Duration(seconds: 1), () {
        if (state.status == StreamingStatus.ready) {
           state = state.copyWith(status: StreamingStatus.completed);
        }
      });
    } catch (e) {
      state = state.copyWith(
        status: StreamingStatus.failed,
        error: "Failed sending END: $e",
      );
    }
  }

  Future<void> abortStreaming() async {
    _scheduleTimer?.cancel();
    
    // We send abort regardless of current state to ensure hardware stops
    try {
      await _robotRepository.sendCommand('TRAJECTORY_CONTROL', {
        'action': 'ABORT',
      });
    } catch (e) {
      // Best effort abort
    }

    state = state.copyWith(status: StreamingStatus.aborted);
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }
}
