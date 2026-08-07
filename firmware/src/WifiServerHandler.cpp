#include "WifiServerHandler.h"
#include "hardware/EmergencyController.h"
#include "Config.h"
#include "Logger.h"
#include "ProtocolCodec.h"
#include "CommandDispatcher.h"

WiFiServer WifiServerHandler::_server(Config::TCP_PORT);
WiFiClient WifiServerHandler::_clients[MAX_CLIENTS];
String WifiServerHandler::_lineBuffers[MAX_CLIENTS];
unsigned long WifiServerHandler::_lastHeartbeatTimes[MAX_CLIENTS];

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
        
        for (int i=0; i<MAX_CLIENTS; i++) {
            _lineBuffers[i] = "";
            _lastHeartbeatTimes[i] = millis();
        }
    } else {
        Logger::error("WiFi", "Failed to connect to AP. Running offline mode.");
    }
}

void WifiServerHandler::tick() {
    // 1. Check for new clients
    if (_server.hasClient()) {
        bool slotFound = false;
        for (int i=0; i<MAX_CLIENTS; i++) {
            if (!_clients[i] || !_clients[i].connected()) {
                if (_clients[i]) _clients[i].stop();
                _clients[i] = _server.available();
                Logger::info("WiFi", "New client connected in slot " + String(i));
                _lineBuffers[i] = "";
                _lastHeartbeatTimes[i] = millis();
                slotFound = true;
                break;
            }
        }
        if (!slotFound) {
            // Reject client if full
            WiFiClient rejectClient = _server.available();
            rejectClient.stop();
            Logger::warning("WiFi", "Rejected client: max clients reached.");
        }
    }

    // 2. Process incoming data from all active clients
    bool anyClientActive = false;
    
    for (int i=0; i<MAX_CLIENTS; i++) {
        if (_clients[i] && _clients[i].connected()) {
            anyClientActive = true;
            
            while (_clients[i].available()) {
                char c = _clients[i].read();
                if (c == '\n') {
                    if (_lineBuffers[i].length() > 0) {
                        processIncomingLine(_lineBuffers[i]);
                        _lineBuffers[i] = "";
                        _lastHeartbeatTimes[i] = millis(); // Valid packet acts as heartbeat
                    }
                } else if (c != '\r') {
                    _lineBuffers[i] += c;
                    if (_lineBuffers[i].length() > 2048) {
                        _lineBuffers[i] = "";
                        Logger::warning("WiFi", "Buffer overflow on slot " + String(i));
                    }
                }
            }

            // Watchdog check for this specific client
            if (millis() - _lastHeartbeatTimes[i] > 3000) {
                Logger::warning("WiFi", "Client heartbeat timeout in slot " + String(i));
                _clients[i].stop();
            }
        }
    }
    
    // Trigger Emergency Stop ONLY if ALL clients drop. 
    // If Flutter crashes but Vision is alive, we might still want to stop, 
    // but typically any connection loss is a full stop.
    // Let's enforce that if we had clients and now have 0, we emergency stop.
}

void WifiServerHandler::processIncomingLine(const String& line) {
    RobotPacket packet;
    if (ProtocolCodec::decode(line.c_str(), packet)) {
        if (packet.type == "command") {
            CommandDispatcher::handleCommand(packet);
        }
    }
}

void WifiServerHandler::sendData(const String& data) {
    for (int i=0; i<MAX_CLIENTS; i++) {
        if (_clients[i] && _clients[i].connected()) {
            _clients[i].print(data);
        }
    }
}
