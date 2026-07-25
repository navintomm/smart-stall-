#include "hardware/EmergencyController.h"
#include "hardware/ServoController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/MotorController.h"
#include "config/pin_map.h"
#include "Logger.h"
#include <Arduino.h>

bool EmergencyController::_isEmergency = false;

void EmergencyController::init() {
    pinMode(Pins::EMERGENCY_SWITCH, INPUT_PULLUP);
    _isEmergency = false;
    Logger::info("HAL", "EmergencyController initialized");
}

void EmergencyController::tick() {
    // Poll hardware switch. Assuming Active-LOW when pressed.
    if (digitalRead(Pins::EMERGENCY_SWITCH) == LOW) {
        if (!_isEmergency) {
            triggerEmergencyStop();
            Logger::error("HAL", "Hardware Emergency Switch PRESSED!");
        }
    }
}

void EmergencyController::triggerEmergencyStop() {
    _isEmergency = true;
    Logger::error("HAL", "HARDWARE EMERGENCY TRIGGERED! Shutting down actuators.");
    
    // Hard kill actuators via HAL interfaces
    MotorController::stop();
    ServoController::stop();
    PumpController::stop(0);
    PumpController::stop(1);
    BrushController::stop();
}

void EmergencyController::reset() {
    _isEmergency = false;
    Logger::info("HAL", "Emergency Reset.");
}

bool EmergencyController::isEmergency() {
    return _isEmergency;
}
