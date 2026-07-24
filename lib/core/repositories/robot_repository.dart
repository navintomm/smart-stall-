abstract class RobotRepository {
  Future<void> sendCommand(String command, Map<String, dynamic> payload);
  Future<void> moveServo(String servoId, int angle);
  Future<void> toggleTool(String toolId, bool state);
  Future<void> triggerEmergencyStop();
}
