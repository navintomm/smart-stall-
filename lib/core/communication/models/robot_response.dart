class RobotResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const RobotResponse({
    required this.success,
    required this.message,
    this.data,
  });
}
