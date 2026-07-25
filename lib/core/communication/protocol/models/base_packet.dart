import 'packet_type.dart';

class RobotPacket {
  final String protocolVersion;
  final PacketType type;
  final int commandId;
  final int sequenceNumber;
  final int timestamp;
  final Map<String, dynamic> payload;
  final int crc;

  const RobotPacket({
    this.protocolVersion = '2.0',
    required this.type,
    this.commandId = 0,
    required this.sequenceNumber,
    required this.timestamp,
    required this.payload,
    this.crc = 0, // 0 = uncalculated
  });

  Map<String, dynamic> toJson() => {
    'ver': protocolVersion,
    'type': type.name,
    'cmdId': commandId,
    'seq': sequenceNumber,
    'ts': timestamp,
    'data': payload,
    'crc': crc,
  };

  factory RobotPacket.fromJson(Map<String, dynamic> json) {
    return RobotPacket(
      protocolVersion: json['ver'] as String? ?? '1.0',
      type: PacketType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PacketType.error,
      ),
      commandId: json['cmdId'] as int? ?? 0,
      sequenceNumber: json['seq'] as int? ?? 0,
      timestamp: json['ts'] as int? ?? 0,
      payload: json['data'] as Map<String, dynamic>? ?? {},
      crc: json['crc'] as int? ?? 0,
    );
  }
}
