#include "hardware/EmergencyController.h"
#include "hardware/ServoController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "Logger.h"

bool EmergencyController::_isEmergency = false;

void EmergencyController::init() {
    _isEmergency = false;
    Logger::info("HAL", "EmergencyController initialized");
}

void EmergencyController::triggerEmergencyStop() {
    _isEmergency = true;
    Logger::error("HAL", "HARDWARE EMERGENCY TRIGGERED! Shutting down actuators.");
    
    // Hard kill actuators via HAL interfaces
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
