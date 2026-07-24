class TelemetryPacket {
  final int timestamp;
  final Map<String, dynamic> readings;

  const TelemetryPacket({
    required this.timestamp,
    required this.readings,
  });
}
