#ifndef PROTOCOL_CODEC_H
#define PROTOCOL_CODEC_H

#include <ArduinoJson.h>

struct RobotPacket {
    String protocolVersion;
    String type;
    int commandId;
    long sequenceNumber;
    long timestamp;
    JsonDocument payload;
    int crc;

    RobotPacket() {}
};

class ProtocolCodec {
public:
    static bool decode(const char* jsonString, RobotPacket& packet);
    static void encode(const RobotPacket& packet, String& outJson);
    static int calculateChecksum(const JsonDocument& payload);
};

#endif // PROTOCOL_CODEC_H
