#include "ProtocolCodec.h"
#include "Logger.h"

bool ProtocolCodec::decode(const char* jsonString, RobotPacket& packet) {
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, jsonString);

    if (error) {
        Logger::error("Codec", "Failed to parse JSON");
        return false;
    }

    if (!doc["ver"].is<String>() || !doc["type"].is<String>() || !doc.containsKey("data")) {
        Logger::error("Codec", "Missing required fields");
        return false;
    }

    packet.protocolVersion = doc["ver"].as<String>();
    packet.type = doc["type"].as<String>();
    packet.commandId = doc["cmdId"] | 0;
    packet.sequenceNumber = doc["seq"] | 0;
    packet.timestamp = doc["ts"] | 0;
    
    // Copy payload
    packet.payload.set(doc["data"]);
    packet.crc = doc["crc"] | 0;

    // Validate CRC
    int calculatedCrc = calculateChecksum(packet.payload);
    if (calculatedCrc != packet.crc) {
        Logger::warning("Codec", "CRC mismatch!");
        return false;
    }

    return true;
}

void ProtocolCodec::encode(const RobotPacket& packet, String& outJson) {
    JsonDocument doc;
    doc["ver"] = packet.protocolVersion.isEmpty() ? "2.0" : packet.protocolVersion;
    doc["type"] = packet.type;
    doc["cmdId"] = packet.commandId;
    doc["seq"] = packet.sequenceNumber;
    doc["ts"] = packet.timestamp;
    doc["data"] = packet.payload;
    doc["crc"] = calculateChecksum(packet.payload);

    serializeJson(doc, outJson);
}

int ProtocolCodec::calculateChecksum(const JsonDocument& payload) {
    String dataStr;
    serializeJson(payload, dataStr);
    
    int sum = 0;
    for (unsigned int i = 0; i < dataStr.length(); i++) {
        sum += dataStr[i];
    }
    return sum % 256;
}
