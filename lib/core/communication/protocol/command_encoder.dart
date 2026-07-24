import 'dart:convert';
import '../models/robot_command.dart';

class CommandEncoder {
  List<int> encode(RobotCommand command) {
    // Placeholder JSON encoder for ESP32 serial/wifi
    final jsonString = jsonEncode({
      'action': command.action,
      'payload': command.payload,
    });
    return utf8.encode(jsonString);
  }
}
