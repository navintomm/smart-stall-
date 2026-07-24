class V1Command {
  final int commandId;
  final String commandType;
  final Map<String, dynamic> payload;
  final int timestamp;
  final String protocolVersion;

  const V1Command({
    required this.commandId,
    required this.commandType,
    required this.payload,
    required this.timestamp,
    this.protocolVersion = '1.0',
  });

  Map<String, dynamic> toJson() => {
    'commandId': commandId,
    'commandType': commandType,
    'payload': payload,
    'timestamp': timestamp,
    'protocolVersion': protocolVersion,
  };
}
