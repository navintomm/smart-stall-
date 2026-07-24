import 'dart:convert';
import '../models/robot_response.dart';

class ResponseDecoder {
  RobotResponse decode(List<int> bytes) {
    try {
      final jsonString = utf8.decode(bytes);
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return RobotResponse(
        success: map['success'] ?? false,
        message: map['message'] ?? '',
        data: map['data'],
      );
    } catch (e) {
      return RobotResponse(success: false, message: 'Decode Error: $e');
    }
  }
}
