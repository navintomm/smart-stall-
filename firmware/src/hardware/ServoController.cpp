#include "hardware/ServoController.h"
#include "config/pin_map.h"
#include "Logger.h"

Servo ServoController::_base;
Servo ServoController::_shoulder;
Servo ServoController::_elbow;
Servo ServoController::_wrist;
Servo ServoController::_gripper;

int ServoController::_angles[5] = {90, 90, 90, 90, 90};
int ServoController::_targetAngles[5] = {90, 90, 90, 90, 90};
unsigned long ServoController::_lastTickTime = 0;

void ServoController::init() {
    ESP32PWM::allocateTimer(0);
    ESP32PWM::allocateTimer(1);
    ESP32PWM::allocateTimer(2);
    ESP32PWM::allocateTimer(3);

    _base.setPeriodHertz(50);
    _shoulder.setPeriodHertz(50);
    _elbow.setPeriodHertz(50);
    _wrist.setPeriodHertz(50);
    _gripper.setPeriodHertz(50);

    _base.attach(Pins::SERVO_BASE, 500, 2400);
    _shoulder.attach(Pins::SERVO_SHOULDER, 500, 2400);
    _elbow.attach(Pins::SERVO_ELBOW, 500, 2400);
    _wrist.attach(Pins::SERVO_WRIST, 500, 2400);
    _gripper.attach(Pins::SERVO_GRIPPER, 500, 2400);

    home();
    _lastTickTime = millis();
    Logger::info("HAL", "ServoController initialized");
}

void ServoController::setAngle(int servoId, int angle) {
    // Safety clamping
    if (angle < 10) angle = 10;
    if (angle > 170) angle = 170;

    if (servoId >= 0 && servoId < 5) {
        _targetAngles[servoId] = angle;
    }
}

void ServoController::tick() {
    unsigned long currentMillis = millis();
    if (currentMillis - _lastTickTime > 15) { // Update every 15ms
        _lastTickTime = currentMillis;

        for (int i = 0; i < 5; i++) {
            if (_angles[i] < _targetAngles[i]) {
                _angles[i]++;
            } else if (_angles[i] > _targetAngles[i]) {
                _angles[i]--;
            } else {
                continue; // At target
            }

            switch (i) {
                case 0: _base.write(_angles[i]); break;
                case 1: _shoulder.write(_angles[i]); break;
                case 2: _elbow.write(_angles[i]); break;
                case 3: _wrist.write(_angles[i]); break;
                case 4: _gripper.write(_angles[i]); break;
            }
        }
    }
}

int ServoController::getAngle(int servoId) {
    if (servoId >= 0 && servoId < 5) return _angles[servoId];
    return -1;
}

void ServoController::home() {
    setAngle(0, 90);
    setAngle(1, 90);
    setAngle(2, 90);
    setAngle(3, 90);
    setAngle(4, 90);
}

void ServoController::stop() {
    // Optional: detach servos to kill holding torque
    _base.detach();
    _shoulder.detach();
    _elbow.detach();
    _wrist.detach();
    _gripper.detach();
    Logger::info("HAL", "Servos detached (stopped)");
}
