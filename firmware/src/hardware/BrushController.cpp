#include "hardware/BrushController.h"
#include "config/pin_map.h"
#include "Logger.h"
#include <Arduino.h>

bool BrushController::_isRunning = false;
int BrushController::_speed = 0;

void BrushController::init() {
    pinMode(Pins::MOTOR_BRUSH, OUTPUT);
    stop();
    Logger::info("HAL", "BrushController initialized");
}

void BrushController::start() {
    _isRunning = true;
    digitalWrite(Pins::MOTOR_BRUSH, HIGH);
}

void BrushController::stop() {
    _isRunning = false;
    digitalWrite(Pins::MOTOR_BRUSH, LOW);
}

void BrushController::setSpeed(int speed) {
    _speed = speed;
    Logger::debug("HAL", "Brush speed setting is a placeholder for PWM");
}

bool BrushController::getStatus() {
    return _isRunning;
}
