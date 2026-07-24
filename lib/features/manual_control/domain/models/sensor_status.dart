class SensorStatus {
  final String id;
  final String name;
  final String value;
  final bool isWarning;

  const SensorStatus({
    required this.id,
    required this.name,
    required this.value,
    this.isWarning = false,
  });

  static List<SensorStatus> get placeholders => [
    const SensorStatus(id: 'sn1', name: 'Water Tank', value: '85%'),
    const SensorStatus(id: 'sn2', name: 'Soap Tank', value: '42%'),
    const SensorStatus(id: 'sn3', name: 'Brush Health', value: 'Good'),
    const SensorStatus(id: 'sn4', name: 'Motor Temp', value: '45°C'),
    const SensorStatus(id: 'sn5', name: 'Battery', value: '12.4V'),
    const SensorStatus(id: 'sn6', name: 'Signal', value: '-65 dBm'),
    const SensorStatus(id: 'sn7', name: 'E-Stop Switch', value: 'Released'),
  ];
}
