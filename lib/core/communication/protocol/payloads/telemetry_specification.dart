class TelemetryPayload {
  final double batteryPercentage;
  final double waterTankLevel;
  final double soapTankLevel;
  final double brushHealth;
  final double motorTemperature;
  final double voltage;
  final double current;
  final int signalStrength;
  final double cpuUsage;
  final double memoryUsage;
  final String robotMode;
  final bool emergencyStatus;
  final String firmwareVersion;
  final int systemUptime;
  final int lastError;
  final int connectionQuality;

  const TelemetryPayload({
    this.batteryPercentage = 0.0,
    this.waterTankLevel = 0.0,
    this.soapTankLevel = 0.0,
    this.brushHealth = 100.0,
    this.motorTemperature = 25.0,
    this.voltage = 12.0,
    this.current = 0.0,
    this.signalStrength = -100,
    this.cpuUsage = 0.0,
    this.memoryUsage = 0.0,
    this.robotMode = 'IDLE',
    this.emergencyStatus = false,
    this.firmwareVersion = '0.0.0',
    this.systemUptime = 0,
    this.lastError = 0,
    this.connectionQuality = 0,
  });

  factory TelemetryPayload.fromJson(Map<String, dynamic> json) {
    return TelemetryPayload(
      batteryPercentage: (json['bat'] ?? 0).toDouble(),
      waterTankLevel: (json['water'] ?? 0).toDouble(),
      soapTankLevel: (json['soap'] ?? 0).toDouble(),
      brushHealth: (json['brush'] ?? 100).toDouble(),
      motorTemperature: (json['temp'] ?? 25).toDouble(),
      voltage: (json['volt'] ?? 12).toDouble(),
      current: (json['amp'] ?? 0).toDouble(),
      signalStrength: json['rssi'] as int? ?? -100,
      cpuUsage: (json['cpu'] ?? 0).toDouble(),
      memoryUsage: (json['mem'] ?? 0).toDouble(),
      robotMode: json['mode'] as String? ?? 'IDLE',
      emergencyStatus: json['estop'] as bool? ?? false,
      firmwareVersion: json['fw'] as String? ?? '0.0.0',
      systemUptime: json['uptime'] as int? ?? 0,
      lastError: json['err'] as int? ?? 0,
      connectionQuality: json['lqi'] as int? ?? 0,
    );
  }
}
