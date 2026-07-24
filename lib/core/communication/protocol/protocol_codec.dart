import 'command_encoder.dart';
import 'response_decoder.dart';
import 'message_parser.dart';

class ProtocolCodec {
  final CommandEncoder encoder;
  final ResponseDecoder decoder;
  final MessageParser parser;

  const ProtocolCodec({
    required this.encoder,
    required this.decoder,
    required this.parser,
  });
}
