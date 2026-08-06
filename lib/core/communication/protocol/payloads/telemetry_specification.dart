class TelemetryPayload {
  final double batteryPercentage;
  final double batteryVoltage;
  final double waterTankLevel;
  final double soapTankLevel;
  final bool brushRunning;
  final bool pumpWaterRunning;
  final bool pumpSoapRunning;
  final double motorTemperature;
  final int signalStrength;
  final double cpuUsage;
  final double memoryUsage;
  final String robotMode;
  final bool emergencyStatus;
  final bool emergencySwitch;
  final String firmwareVersion;
  final int systemUptime;
  final int obstacleDistance;
  final int motorSpeed;
  final String motorDirection;
  final List<int> servoAngles;
  final String cleanState;
  final String cleanStep;
  final int cleanProgress;
  final int cleanRemaining;
  final int cleanElapsed;
  final int cleanCycle;
  final String abortReason;
  final String camStatus;
  final int camFps;
  final int markerId;
  final double markerDist;
  final double markerConf;
  final String locState;
  final int alignScore;
  final double poseX;
  final double poseY;
  final double poseZ;
  final double poseRoll;
  final double posePitch;
  final double poseYaw;
  final int lastDetTime;
  
  final String missionState;
  final int currentWaypoint;
  final int targetWaypoint;
  final int navigationProgress;
  final double distanceRemaining;
  final int missionTime;
  final int missionCount;
  final String navState;

  const TelemetryPayload({
    this.batteryPercentage = 0.0,
    this.batteryVoltage = 12.0,
    this.waterTankLevel = 0.0,
    this.soapTankLevel = 0.0,
    this.brushRunning = false,
    this.pumpWaterRunning = false,
    this.pumpSoapRunning = false,
    this.motorTemperature = 25.0,
    this.signalStrength = -100,
    this.cpuUsage = 0.0,
    this.memoryUsage = 0.0,
    this.robotMode = 'IDLE',
    this.emergencyStatus = false,
    this.emergencySwitch = false,
    this.firmwareVersion = '0.0.0',
    this.systemUptime = 0,
    this.obstacleDistance = 999,
    this.motorSpeed = 0,
    this.motorDirection = 'STOP',
    this.servoAngles = const [90, 90, 90, 90, 90],
    this.cleanState = 'IDLE',
    this.cleanStep = 'Idle',
    this.cleanProgress = 0,
    this.cleanRemaining = 0,
    this.cleanElapsed = 0,
    this.cleanCycle = 0,
    this.abortReason = '',
    this.camStatus = 'UNKNOWN',
    this.camFps = 0,
    this.markerId = 0,
    this.markerDist = 0.0,
    this.markerConf = 0.0,
    this.locState = 'UNKNOWN',
    this.alignScore = 0,
    this.poseX = 0.0,
    this.poseY = 0.0,
    this.poseZ = 0.0,
    this.poseRoll = 0.0,
    this.posePitch = 0.0,
    this.poseYaw = 0.0,
    this.lastDetTime = 0,
    this.missionState = 'IDLE',
    this.currentWaypoint = -1,
    this.targetWaypoint = -1,
    this.navigationProgress = 0,
    this.distanceRemaining = 0.0,
    this.missionTime = 0,
    this.missionCount = 0,
    this.navState = 'IDLE',
  });

  factory TelemetryPayload.fromJson(Map<String, dynamic> json) {
    return TelemetryPayload(
      batteryPercentage: (json['bat'] ?? 0).toDouble(),
      batteryVoltage: (json['bat_v'] ?? 12.0).toDouble(),
      waterTankLevel: (json['water'] ?? 0).toDouble(),
      soapTankLevel: (json['soap'] ?? 0).toDouble(),
      brushRunning: json['brush'] as bool? ?? false,
      pumpWaterRunning: json['pump_w'] as bool? ?? false,
      pumpSoapRunning: json['pump_s'] as bool? ?? false,
      motorTemperature: (json['temp'] ?? 25).toDouble(),
      signalStrength: json['rssi'] as int? ?? -100,
      cpuUsage: (json['cpu'] ?? 0).toDouble(),
      memoryUsage: (json['mem'] ?? 0).toDouble(),
      robotMode: json['mode'] as String? ?? 'IDLE',
      emergencyStatus: json['emg'] as bool? ?? false,
      emergencySwitch: json['emg_sw'] as bool? ?? false,
      firmwareVersion: json['fw'] as String? ?? '0.0.0',
      systemUptime: json['uptime'] as int? ?? 0,
      obstacleDistance: json['obs'] as int? ?? 999,
      motorSpeed: json['motor_speed'] as int? ?? 0,
      motorDirection: json['motor_dir'] as String? ?? 'STOP',
      servoAngles: (json['servos'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [90, 90, 90, 90, 90],
      cleanState: json['clean_state'] as String? ?? 'IDLE',
      cleanStep: json['clean_step'] as String? ?? 'Idle',
      cleanProgress: json['clean_progress'] as int? ?? 0,
      cleanRemaining: json['clean_remaining'] as int? ?? 0,
      cleanElapsed: json['clean_elapsed'] as int? ?? 0,
      cleanCycle: json['clean_cycle'] as int? ?? 0,
      abortReason: json['abort_reason'] as String? ?? '',
      camStatus: json['cam_status'] as String? ?? 'UNKNOWN',
      camFps: json['cam_fps'] as int? ?? 0,
      markerId: json['marker_id'] as int? ?? 0,
      markerDist: (json['marker_dist'] ?? 0).toDouble(),
      markerConf: (json['marker_conf'] ?? 0).toDouble(),
      locState: json['loc_state'] as String? ?? 'UNKNOWN',
      alignScore: json['align_score'] as int? ?? 0,
      poseX: (json['pose_x'] ?? 0).toDouble(),
      poseY: (json['pose_y'] ?? 0).toDouble(),
      poseZ: (json['pose_z'] ?? 0).toDouble(),
      poseRoll: (json['pose_roll'] ?? 0).toDouble(),
      posePitch: (json['pose_pitch'] ?? 0).toDouble(),
      poseYaw: (json['pose_yaw'] ?? 0).toDouble(),
      lastDetTime: json['last_det_time'] as int? ?? 0,
      missionState: json['mission_state'] as String? ?? 'IDLE',
      currentWaypoint: json['current_waypoint'] as int? ?? -1,
      targetWaypoint: json['target_waypoint'] as int? ?? -1,
      navigationProgress: json['navigation_progress'] as int? ?? 0,
      distanceRemaining: (json['distance_remaining'] ?? 0).toDouble(),
      missionTime: json['mission_time'] as int? ?? 0,
      missionCount: json['mission_count'] as int? ?? 0,
      navState: json['nav_state'] as String? ?? 'IDLE',
    );
  }
}
