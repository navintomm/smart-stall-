class V1Telemetry {
  final int batteryLevel;
  final int waterTankLevel;
  final int soapTankLevel;
  final int brushWear;
  final int motorTemperature;
  final int signalStrength;
  final String firmwareVersion;
  final String robotMode;
  final bool emergencyState;
  final int uptime;

  const V1Telemetry({
    required this.batteryLevel,
    required this.waterTankLevel,
    required this.soapTankLevel,
    required this.brushWear,
    required this.motorTemperature,
    required this.signalStrength,
    required this.firmwareVersion,
    required this.robotMode,
    required this.emergencyState,
    required this.uptime,
  });

  factory V1Telemetry.fromJson(Map<String, dynamic> json) {
    return V1Telemetry(
      batteryLevel: json['battery'] ?? 0,
      waterTankLevel: json['water'] ?? 0,
      soapTankLevel: json['soap'] ?? 0,
      brushWear: json['brush'] ?? 0,
      motorTemperature: json['temp'] ?? 0,
      signalStrength: json['rssi'] ?? -100,
      firmwareVersion: json['fw'] ?? 'unknown',
      robotMode: json['mode'] ?? 'IDLE',
      emergencyState: json['estop'] ?? false,
      uptime: json['uptime'] ?? 0,
    );
  }
}
