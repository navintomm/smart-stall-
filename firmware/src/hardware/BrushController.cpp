#include "hardware/BrushController.h"
#include "config/pin_map.h"
#include "Logger.h"
#include <Arduino.h>

bool BrushController::_isRunning = false;
int BrushController::_speed = 0;
unsigned long BrushController::_startTime = 0;

const unsigned long BRUSH_MAX_RUNTIME_MS = 60000; // 60 seconds safety timeout

void BrushController::init() {
    pinMode(Pins::MOTOR_BRUSH, OUTPUT);
    stop();
    Logger::info("HAL", "BrushController initialized");
}

void BrushController::start() {
    if (!_isRunning) {
        _isRunning = true;
        _startTime = millis();
        digitalWrite(Pins::MOTOR_BRUSH, HIGH);
    }
}

void BrushController::stop() {
    _isRunning = false;
    digitalWrite(Pins::MOTOR_BRUSH, LOW);
}

void BrushController::tick() {
    unsigned long currentMillis = millis();
    
    // Check Brush Timeout
    if (_isRunning && (currentMillis - _startTime > BRUSH_MAX_RUNTIME_MS)) {
        stop();
        Logger::error("HAL", "Brush Motor auto-shutoff triggered! (Timeout)");
    }
}

void BrushController::setSpeed(int speed) {
    _speed = speed;
    Logger::debug("HAL", "Brush speed setting is a placeholder for PWM");
}

bool BrushController::getStatus() {
    return _isRunning;
}
