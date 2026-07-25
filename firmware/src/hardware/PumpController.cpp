#include "hardware/PumpController.h"
#include "config/pin_map.h"
#include "Logger.h"
#include <Arduino.h>

bool PumpController::_waterPumpState = false;
bool PumpController::_soapPumpState = false;
unsigned long PumpController::_waterPumpStartTime = 0;
unsigned long PumpController::_soapPumpStartTime = 0;

const unsigned long PUMP_MAX_RUNTIME_MS = 30000; // 30 seconds safety timeout

void PumpController::init() {
    pinMode(Pins::PUMP_WATER, OUTPUT);
    pinMode(Pins::PUMP_SOAP, OUTPUT);
    stop(0); // water
    stop(1); // soap
    Logger::info("HAL", "PumpController initialized");
}

void PumpController::start(int pumpId) {
    if (pumpId == 0) {
        if (!_waterPumpState) {
            digitalWrite(Pins::PUMP_WATER, HIGH);
            _waterPumpState = true;
            _waterPumpStartTime = millis();
        }
    } else if (pumpId == 1) {
        if (!_soapPumpState) {
            digitalWrite(Pins::PUMP_SOAP, HIGH);
            _soapPumpState = true;
            _soapPumpStartTime = millis();
        }
    }
}

void PumpController::stop(int pumpId) {
    if (pumpId == 0) {
        digitalWrite(Pins::PUMP_WATER, LOW);
        _waterPumpState = false;
    } else if (pumpId == 1) {
        digitalWrite(Pins::PUMP_SOAP, LOW);
        _soapPumpState = false;
    }
}

void PumpController::tick() {
    unsigned long currentMillis = millis();
    
    // Check Water Pump Timeout
    if (_waterPumpState && (currentMillis - _waterPumpStartTime > PUMP_MAX_RUNTIME_MS)) {
        stop(0);
        Logger::error("HAL", "Water Pump auto-shutoff triggered! (Timeout)");
    }
    
    // Check Soap Pump Timeout
    if (_soapPumpState && (currentMillis - _soapPumpStartTime > PUMP_MAX_RUNTIME_MS)) {
        stop(1);
        Logger::error("HAL", "Soap Pump auto-shutoff triggered! (Timeout)");
    }
}

void PumpController::setFlowRate(int pumpId, int rate) {
    // Placeholder for future PWM pump control
    Logger::debug("HAL", "Pump flow rate setting is a placeholder");
}

bool PumpController::getStatus(int pumpId) {
    return pumpId == 0 ? _waterPumpState : _soapPumpState;
}
