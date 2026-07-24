class ConnectionHistory {
  final String timestamp;
  final String robotName;
  final String type;
  final String status;
  final String duration;

  const ConnectionHistory({
    required this.timestamp,
    required this.robotName,
    required this.type,
    required this.status,
    required this.duration,
  });

  static List<ConnectionHistory> get placeholders => [
    const ConnectionHistory(timestamp: '14:20:00', robotName: 'AlphaBot-01', type: 'Wi-Fi', status: 'Connected', duration: '1h 12m'),
    const ConnectionHistory(timestamp: '12:05:33', robotName: 'AlphaBot-01', type: 'Wi-Fi', status: 'Disconnected', duration: '4h 0m'),
    const ConnectionHistory(timestamp: '10:15:10', robotName: 'AlphaBot-02', type: 'Bluetooth', status: 'Failed', duration: '0m'),
    const ConnectionHistory(timestamp: '08:00:00', robotName: 'AlphaBot-01', type: 'Wi-Fi', status: 'Connected', duration: '2h 15m'),
  ];
}
