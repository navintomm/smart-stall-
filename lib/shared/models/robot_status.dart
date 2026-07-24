class RobotStatus {
  final String id;
  final String state;
  final int batteryLevel;

  const RobotStatus({
    required this.id,
    required this.state,
    required this.batteryLevel,
  });

  static List<RobotStatus> get placeholders => [
    const RobotStatus(id: 'AlphaBot-01', state: 'ACTIVE', batteryLevel: 87),
  ];
}
