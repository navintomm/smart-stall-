#include "hardware/PumpController.h"
#include "config/pin_map.h"
#include "Logger.h"
#include <Arduino.h>

bool PumpController::_waterPumpState = false;
bool PumpController::_soapPumpState = false;

void PumpController::init() {
    pinMode(Pins::PUMP_WATER, OUTPUT);
    pinMode(Pins::PUMP_SOAP, OUTPUT);
    stop(0); // water
    stop(1); // soap
    Logger::info("HAL", "PumpController initialized");
}

void PumpController::start(int pumpId) {
    if (pumpId == 0) {
        digitalWrite(Pins::PUMP_WATER, HIGH);
        _waterPumpState = true;
    } else if (pumpId == 1) {
        digitalWrite(Pins::PUMP_SOAP, HIGH);
        _soapPumpState = true;
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

void PumpController::setFlowRate(int pumpId, int rate) {
    // Placeholder for future PWM pump control
    Logger::debug("HAL", "Pump flow rate setting is a placeholder");
}

bool PumpController::getStatus(int pumpId) {
    return pumpId == 0 ? _waterPumpState : _soapPumpState;
}
