#include "WifiServerHandler.h"
#include "hardware/EmergencyController.h"
#include "Config.h"
#include "Logger.h"
#include "ProtocolCodec.h"
#include "CommandDispatcher.h"

WiFiServer WifiServerHandler::_server(Config::TCP_PORT);
WiFiClient WifiServerHandler::_client;
String WifiServerHandler::_lineBuffer = "";
unsigned long WifiServerHandler::_lastHeartbeatTime = 0;

void WifiServerHandler::init() {
    Logger::info("WiFi", "Connecting to AP...");
    WiFi.begin(Config::WIFI_SSID, Config::WIFI_PASS);

    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
        delay(500);
        Serial.print(".");
        attempts++;
    }
    Serial.println();

    if (WiFi.status() == WL_CONNECTED) {
        Logger::info("WiFi", "Connected!");
        Serial.print("[INFO] IP Address: ");
        Serial.println(WiFi.localIP());
        
        _server.begin();
        Logger::info("WiFi", "TCP Server started on port 8888");
    } else {
        Logger::error("WiFi", "Failed to connect to AP. Running offline mode.");
    }
}

void WifiServerHandler::tick() {
    // Check for new clients if we don't have one
    if (!_client || !_client.connected()) {
        WiFiClient newClient = _server.available();
        if (newClient) {
            _client = newClient;
            Logger::info("WiFi", "New client connected.");
            _lineBuffer = ""; // Reset buffer
            _lastHeartbeatTime = millis();
        }
    }

    // Process incoming data
    if (_client && _client.connected()) {
        while (_client.available()) {
            char c = _client.read();
            if (c == '\n') {
                // Process the complete packet
                if (_lineBuffer.length() > 0) {
                    processIncomingLine(_lineBuffer);
                    _lineBuffer = "";
                    _lastHeartbeatTime = millis(); // Any valid packet acts as heartbeat
                }
            } else if (c != '\r') {
                // Ignore CR, append other chars
                _lineBuffer += c;
                // Basic protection against buffer overflow
                if (_lineBuffer.length() > 2048) {
                    _lineBuffer = "";
                    Logger::warning("WiFi", "Buffer overflow, dropping chunk.");
                }
            }
        }

        // Watchdog check
        if (millis() - _lastHeartbeatTime > 3000) {
            Logger::error("WiFi", "WATCHDOG TIMEOUT! No heartbeat received.");
            EmergencyController::triggerEmergencyStop();
            _client.stop(); // Drop client
        }
    }
}

void WifiServerHandler::processIncomingLine(const String& line) {
    RobotPacket packet;
    if (ProtocolCodec::decode(line.c_str(), packet)) {
        if (packet.type == "command") {
            CommandDispatcher::handleCommand(packet);
        } else {
            Logger::debug("WiFi", "Received non-command packet type.");
        }
    }
}

void WifiServerHandler::sendData(const String& data) {
    if (_client && _client.connected()) {
        _client.print(data);
    }
}
