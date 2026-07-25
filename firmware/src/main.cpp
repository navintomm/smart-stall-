#include <Arduino.h>
#include "Config.h"
#include "Logger.h"
#include "RobotState.h"
#include "WifiServerHandler.h"
#include "TelemetryEngine.h"

// HAL
#include "hardware/ServoController.h"
#include "hardware/MotorController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/SensorManager.h"
#include "hardware/EmergencyController.h"
#include "hardware/SelfTest.h"

void setup() {
    Logger::init(115200);
    Logger::info("Main", "Initializing SmartStall Firmware Core...");
    
    // Initialize HAL
    ServoController::init();
    MotorController::init();
    PumpController::init();
    BrushController::init();
    SensorManager::init();
    EmergencyController::init();

    // Run Hardware Self-Test
    SelfTest::run();
    
    RobotState::init();
    WifiServerHandler::init();
    TelemetryEngine::init();
    
    Logger::info("Main", "Initialization Complete.");
}

void loop() {
    // 1. Maintain TCP connections and process incoming packets
    WifiServerHandler::tick();
    
    // 2. Hardware non-blocking ticks
    EmergencyController::tick();
    ServoController::tick();
    PumpController::tick();
    BrushController::tick();
    
    // 3. Update dummy internal state (battery drain, temps) via HAL
    SensorManager::update();
    
    // 4. Broadcast telemetry 1Hz
    TelemetryEngine::tick([](const String& outJson) {
        WifiServerHandler::sendData(outJson);
    });
    
    // Tiny delay to prevent WDT resets
    delay(10);
}
