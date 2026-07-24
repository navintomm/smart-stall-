class RobotCommand {
  final String action;
  final Map<String, dynamic> payload;

  const RobotCommand({
    required this.action,
    this.payload = const {},
  });
}
