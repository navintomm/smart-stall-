class CommandDefinition {
  final int id;
  final String name;
  final String category;
  final List<String> requiredPayloadKeys;
  final bool expectsResponse;
  final int timeoutMs;
  final int maxRetries;

  const CommandDefinition({
    required this.id,
    required this.name,
    required this.category,
    this.requiredPayloadKeys = const [],
    this.expectsResponse = true,
    this.timeoutMs = 2000,
    this.maxRetries = 3,
  });
}

class CommandCatalog {
  // Movement
  static const moveForward = CommandDefinition(id: 101, name: 'MOVE_FORWARD', category: 'Movement', requiredPayloadKeys: ['speed']);
  static const moveBackward = CommandDefinition(id: 102, name: 'MOVE_BACKWARD', category: 'Movement', requiredPayloadKeys: ['speed']);
  static const turnLeft = CommandDefinition(id: 103, name: 'TURN_LEFT', category: 'Movement', requiredPayloadKeys: ['speed']);
  static const turnRight = CommandDefinition(id: 104, name: 'TURN_RIGHT', category: 'Movement', requiredPayloadKeys: ['speed']);
  static const stop = CommandDefinition(id: 105, name: 'STOP', category: 'Movement');

  // Robot Arm
  static const baseRotation = CommandDefinition(id: 201, name: 'BASE_ROTATION', category: 'Arm', requiredPayloadKeys: ['angle']);
  static const shoulder = CommandDefinition(id: 202, name: 'SHOULDER', category: 'Arm', requiredPayloadKeys: ['angle']);
  static const elbow = CommandDefinition(id: 203, name: 'ELBOW', category: 'Arm', requiredPayloadKeys: ['angle']);
  static const wrist = CommandDefinition(id: 204, name: 'WRIST', category: 'Arm', requiredPayloadKeys: ['angle']);
  static const gripper = CommandDefinition(id: 205, name: 'GRIPPER', category: 'Arm', requiredPayloadKeys: ['state']);

  // Cleaning Tools
  static const waterPump = CommandDefinition(id: 301, name: 'WATER_PUMP', category: 'Tools', requiredPayloadKeys: ['state']);
  static const soapPump = CommandDefinition(id: 302, name: 'SOAP_PUMP', category: 'Tools', requiredPayloadKeys: ['state']);
  static const brushMotor = CommandDefinition(id: 303, name: 'BRUSH_MOTOR', category: 'Tools', requiredPayloadKeys: ['state']);
  static const brushRotation = CommandDefinition(id: 304, name: 'BRUSH_ROTATION', category: 'Tools', requiredPayloadKeys: ['speed']);

  // System
  static const emergencyStop = CommandDefinition(id: 401, name: 'EMERGENCY_STOP', category: 'System', maxRetries: 10);
  static const resume = CommandDefinition(id: 402, name: 'RESUME', category: 'System');
  static const restart = CommandDefinition(id: 403, name: 'RESTART', category: 'System', expectsResponse: false);
  static const calibration = CommandDefinition(id: 404, name: 'CALIBRATION', category: 'System', timeoutMs: 10000);
  static const homePosition = CommandDefinition(id: 405, name: 'HOME_POSITION', category: 'System', timeoutMs: 5000);
  static const ping = CommandDefinition(id: 406, name: 'PING', category: 'System', timeoutMs: 500);

  // Cleaning
  static const startCleaning = CommandDefinition(id: 501, name: 'START_CLEANING', category: 'Cleaning');
  static const pauseCleaning = CommandDefinition(id: 502, name: 'PAUSE_CLEANING', category: 'Cleaning');
  static const resumeCleaning = CommandDefinition(id: 503, name: 'RESUME_CLEANING', category: 'Cleaning');
  static const stopCleaning = CommandDefinition(id: 504, name: 'STOP_CLEANING', category: 'Cleaning');

  // Mission Control
  static const missionStart = CommandDefinition(id: 601, name: 'MISSION_START', category: 'Mission', requiredPayloadKeys: ['waypoints']);
  static const missionPause = CommandDefinition(id: 602, name: 'MISSION_PAUSE', category: 'Mission');
  static const missionResume = CommandDefinition(id: 603, name: 'MISSION_RESUME', category: 'Mission');
  static const missionCancel = CommandDefinition(id: 604, name: 'MISSION_CANCEL', category: 'Mission');

  static const List<CommandDefinition> allCommands = [
    moveForward, moveBackward, turnLeft, turnRight, stop,
    baseRotation, shoulder, elbow, wrist, gripper,
    waterPump, soapPump, brushMotor, brushRotation,
    emergencyStop, resume, restart, calibration, homePosition, ping,
    startCleaning, pauseCleaning, resumeCleaning, stopCleaning,
    missionStart, missionPause, missionResume, missionCancel,
  ];

  static CommandDefinition? getById(int id) {
    try {
      return allCommands.firstWhere((cmd) => cmd.id == id);
    } catch (_) {
      return null;
    }
  }
}
