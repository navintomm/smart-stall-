import 'dart:convert';
import 'models/base_packet.dart';

class ProtocolCodec {
  static const String endMarker = '\n';

  List<int> encode(RobotPacket packet) {
    final jsonString = jsonEncode(packet.toJson());
    return utf8.encode(jsonString + endMarker);
  }

  RobotPacket? decode(List<int> bytes) {
    try {
      final str = utf8.decode(bytes);
      final cleanStr = str.endsWith(endMarker) ? str.substring(0, str.length - endMarker.length) : str;
      final map = jsonDecode(cleanStr) as Map<String, dynamic>;
      return RobotPacket.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  String prettyPrint(RobotPacket packet) {
    return const JsonEncoder.withIndent('  ').convert(packet.toJson());
  }
}
