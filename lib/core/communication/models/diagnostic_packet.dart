class DiagnosticPacket {
  final int pingMs;
  final double packetLoss;
  final int signalDbm;

  const DiagnosticPacket({
    required this.pingMs,
    required this.packetLoss,
    required this.signalDbm,
  });
}
