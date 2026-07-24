class ServoControl {
  final String id;
  final String name;
  final double currentAngle;
  final double minAngle;
  final double maxAngle;

  const ServoControl({
    required this.id,
    required this.name,
    required this.currentAngle,
    this.minAngle = 0.0,
    this.maxAngle = 180.0,
  });

  static List<ServoControl> get placeholders => [
    const ServoControl(id: 's1', name: 'Base Rotation', currentAngle: 90.0),
    const ServoControl(id: 's2', name: 'Shoulder', currentAngle: 45.0),
    const ServoControl(id: 's3', name: 'Elbow', currentAngle: 120.0),
    const ServoControl(id: 's4', name: 'Wrist', currentAngle: 90.0),
    const ServoControl(id: 's5', name: 'Gripper', currentAngle: 10.0),
  ];
}
