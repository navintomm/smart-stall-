#include "TelemetryEngine.h"
#include "Config.h"
#include "RobotState.h"
#include "ProtocolCodec.h"
#include "hardware/SensorManager.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/EmergencyController.h"
#include "hardware/ServoController.h"
#include "hardware/MotorController.h"
#include <WiFi.h>

unsigned long TelemetryEngine::_lastTelemetryTime = 0;

void TelemetryEngine::init() {
    _lastTelemetryTime = millis();
}

void TelemetryEngine::tick(void (*sendCallback)(const String&)) {
    unsigned long currentMillis = millis();
    
    if (currentMillis - _lastTelemetryTime >= Config::TELEMETRY_INTERVAL_MS) {
        _lastTelemetryTime = currentMillis;

        RobotPacket packet;
        packet.type = "telemetry";
        packet.protocolVersion = Config::PROTOCOL_VERSION;
        packet.timestamp = currentMillis;
        packet.sequenceNumber = currentMillis; // Simple placeholder seq
        
        packet.payload["bat"] = SensorManager::getBatteryLevel();
        packet.payload["water"] = SensorManager::getWaterLevel();
        packet.payload["soap"] = SensorManager::getSoapLevel();
        packet.payload["temp"] = SensorManager::getMotorTemp();
        
        packet.payload["pump_w"] = PumpController::getStatus(0);
        packet.payload["pump_s"] = PumpController::getStatus(1);
        packet.payload["brush"] = BrushController::getStatus();
        packet.payload["emg"] = EmergencyController::isEmergency();

        packet.payload["motor_speed"] = MotorController::getCurrentSpeed();
        packet.payload["motor_dir"] = MotorController::getCurrentDirection();
        
        // Use a nested JSON object or array for servo angles
        JsonArray servos = packet.payload["servos"].to<JsonArray>();
        for(int i=0; i<5; i++) {
            servos.add(ServoController::getAngle(i));
        }

        #ifdef ESP32
        packet.payload["rssi"] = WiFi.RSSI();
        #else
        packet.payload["rssi"] = -50;
        #endif

        packet.payload["mode"] = RobotState::getMode();
        packet.payload["uptime"] = currentMillis / 1000;

        String outJson;
        ProtocolCodec::encode(packet, outJson);
        
        // Append newline delimiter
        outJson += "\n";
        
        if (sendCallback != nullptr) {
            sendCallback(outJson);
        }
    }
}
