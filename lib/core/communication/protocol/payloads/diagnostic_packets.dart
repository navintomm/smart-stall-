class DiagnosticPayload {
  final Map<String, dynamic> motorDiagnostics;
  final Map<String, dynamic> pumpDiagnostics;
  final Map<String, dynamic> sensorDiagnostics;
  final Map<String, dynamic> commDiagnostics;
  final Map<String, dynamic> systemDiagnostics;

  const DiagnosticPayload({
    this.motorDiagnostics = const {},
    this.pumpDiagnostics = const {},
    this.sensorDiagnostics = const {},
    this.commDiagnostics = const {},
    this.systemDiagnostics = const {},
  });

  factory DiagnosticPayload.fromJson(Map<String, dynamic> json) {
    return DiagnosticPayload(
      motorDiagnostics: json['motor'] as Map<String, dynamic>? ?? {},
      pumpDiagnostics: json['pump'] as Map<String, dynamic>? ?? {},
      sensorDiagnostics: json['sensor'] as Map<String, dynamic>? ?? {},
      commDiagnostics: json['comm'] as Map<String, dynamic>? ?? {},
      systemDiagnostics: json['sys'] as Map<String, dynamic>? ?? {},
    );
  }
}
