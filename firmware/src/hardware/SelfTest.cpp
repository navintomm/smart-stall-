#include "hardware/SelfTest.h"
#include "hardware/ServoController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/SensorManager.h"
#include "Logger.h"
#include <Arduino.h>

void SelfTest::run() {
    Logger::info("SelfTest", "Starting Hardware Self-Test Sequence...");

    // Test Servos
    Logger::info("SelfTest", "Homing Servos...");
    ServoController::home();
    delay(500);

    // Test Pumps
    Logger::info("SelfTest", "Testing Water Pump (ON/OFF)...");
    PumpController::start(0);
    delay(200);
    PumpController::stop(0);

    Logger::info("SelfTest", "Testing Soap Pump (ON/OFF)...");
    PumpController::start(1);
    delay(200);
    PumpController::stop(1);

    // Test Brush
    Logger::info("SelfTest", "Testing Brush Motor...");
    BrushController::start();
    delay(200);
    BrushController::stop();

    // Check Sensors
    SensorManager::update();
    Logger::info("SelfTest", "Reading Initial Sensors...");
    Serial.printf("[SelfTest] Battery: %d, Water: %d, Soap: %d\n", 
                  SensorManager::getBatteryLevel(), 
                  SensorManager::getWaterLevel(), 
                  SensorManager::getSoapLevel());

    Logger::info("SelfTest", "Self-Test Complete. Hardware is READY.");
}
