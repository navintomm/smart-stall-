#include "hardware/MotorController.h"
#include "config/pin_map.h"
#include "Logger.h"
#include <Arduino.h>

int MotorController::_currentSpeed = 0;
const char* MotorController::_currentDirection = "STOP";

void MotorController::init() {
    pinMode(Pins::MOTOR_LEFT_PWM, OUTPUT);
    pinMode(Pins::MOTOR_LEFT_DIR, OUTPUT);
    pinMode(Pins::MOTOR_RIGHT_PWM, OUTPUT);
    pinMode(Pins::MOTOR_RIGHT_DIR, OUTPUT);
    
    stop();
    Logger::info("HAL", "MotorController initialized");
}

void MotorController::writeMotors(int leftPwm, bool leftFwd, int rightPwm, bool rightFwd) {
    digitalWrite(Pins::MOTOR_LEFT_DIR, leftFwd ? HIGH : LOW);
    analogWrite(Pins::MOTOR_LEFT_PWM, leftPwm);
    
    digitalWrite(Pins::MOTOR_RIGHT_DIR, rightFwd ? HIGH : LOW);
    analogWrite(Pins::MOTOR_RIGHT_PWM, rightPwm);
}

void MotorController::moveForward(int speed) {
    if (speed < 0) speed = 0;
    if (speed > 255) speed = 255;
    
    _currentSpeed = speed;
    _currentDirection = "FORWARD";
    writeMotors(speed, true, speed, true);
}

void MotorController::moveBackward(int speed) {
    if (speed < 0) speed = 0;
    if (speed > 255) speed = 255;
    
    _currentSpeed = speed;
    _currentDirection = "BACKWARD";
    writeMotors(speed, false, speed, false);
}

void MotorController::turnLeft(int speed) {
    if (speed < 0) speed = 0;
    if (speed > 255) speed = 255;
    
    _currentSpeed = speed;
    _currentDirection = "LEFT";
    writeMotors(speed, false, speed, true);
}

void MotorController::turnRight(int speed) {
    if (speed < 0) speed = 0;
    if (speed > 255) speed = 255;
    
    _currentSpeed = speed;
    _currentDirection = "RIGHT";
    writeMotors(speed, true, speed, false);
}

void MotorController::stop() {
    _currentSpeed = 0;
    _currentDirection = "STOP";
    writeMotors(0, true, 0, true);
}

int MotorController::getCurrentSpeed() {
    return _currentSpeed;
}

const char* MotorController::getCurrentDirection() {
    return _currentDirection;
}
