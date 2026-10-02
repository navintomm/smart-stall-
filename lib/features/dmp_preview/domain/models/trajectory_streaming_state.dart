enum StreamingStatus {
  idle,
  preparing,
  sendingBegin,
  streaming,
  sendingEnd,
  ready, // Hardware received all chunks, waiting to start or started
  failed,
  aborted,
  completed
}

class TrajectoryStreamingState {
  final StreamingStatus status;
  final int currentChunk;
  final int totalChunks;
  final int samplesTransmitted;
  final int totalSamples;
  final String? error;
  final String? trajectoryId;

  const TrajectoryStreamingState({
    this.status = StreamingStatus.idle,
    this.currentChunk = 0,
    this.totalChunks = 0,
    this.samplesTransmitted = 0,
    this.totalSamples = 0,
    this.error,
    this.trajectoryId,
  });

  TrajectoryStreamingState copyWith({
    StreamingStatus? status,
    int? currentChunk,
    int? totalChunks,
    int? samplesTransmitted,
    int? totalSamples,
    String? error,
    String? trajectoryId,
  }) {
    return TrajectoryStreamingState(
      status: status ?? this.status,
      currentChunk: currentChunk ?? this.currentChunk,
      totalChunks: totalChunks ?? this.totalChunks,
      samplesTransmitted: samplesTransmitted ?? this.samplesTransmitted,
      totalSamples: totalSamples ?? this.totalSamples,
      error: error,
      trajectoryId: trajectoryId ?? this.trajectoryId,
    );
  }

  double get progress {
    if (totalChunks == 0) return 0.0;
    return currentChunk / totalChunks;
  }
}
