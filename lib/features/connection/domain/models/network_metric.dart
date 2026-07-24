class NetworkMetric {
  final String name;
  final String value;
  final bool isWarning;

  const NetworkMetric({
    required this.name,
    required this.value,
    this.isWarning = false,
  });

  static List<NetworkMetric> get placeholders => [
    const NetworkMetric(name: 'Signal Strength', value: '-65 dBm'),
    const NetworkMetric(name: 'Packet Loss', value: '0.01%'),
    const NetworkMetric(name: 'Response Time', value: '12ms'),
    const NetworkMetric(name: 'Stability', value: '99.9%'),
    const NetworkMetric(name: 'Jitter', value: '2ms'),
    const NetworkMetric(name: 'Network Health', value: 'Excellent'),
  ];
}
