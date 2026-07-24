class RobotDevice {
  final String id;
  final String name;
  final String status;
  final String type;
  final int signalQuality;
  final bool isFavorite;

  const RobotDevice({
    required this.id,
    required this.name,
    required this.status,
    required this.type,
    required this.signalQuality,
    this.isFavorite = false,
  });

  static List<RobotDevice> get placeholders => [
    const RobotDevice(id: 'r001', name: 'AlphaBot-01', status: 'Online', type: 'Wi-Fi', signalQuality: 95, isFavorite: true),
    const RobotDevice(id: 'r002', name: 'AlphaBot-02', status: 'Offline', type: 'Bluetooth', signalQuality: 0, isFavorite: false),
    const RobotDevice(id: 'r003', name: 'AlphaBot-03', status: 'Standby', type: 'Wi-Fi', signalQuality: 70, isFavorite: false),
  ];
}
