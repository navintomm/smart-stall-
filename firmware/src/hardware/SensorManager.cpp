#include "hardware/SensorManager.h"
#include "config/pin_map.h"
#include "Logger.h"
#include <Arduino.h>

int SensorManager::_batteryLevel = 100;
int SensorManager::_waterLevel = 100;
int SensorManager::_soapLevel = 100;
int SensorManager::_motorTemp = 25;
int SensorManager::_obstacleDistance = 999;
float SensorManager::_batteryVoltage = 12.0f;

void SensorManager::init() {
    pinMode(Pins::SENSOR_WATER_LVL, INPUT);
    pinMode(Pins::SENSOR_SOAP_LVL, INPUT);
    pinMode(Pins::SENSOR_BATTERY, INPUT);
    pinMode(Pins::SENSOR_OBSTACLE, INPUT);
    Logger::info("HAL", "SensorManager initialized");
}

void SensorManager::update() {
    // Real hardware ADC reads (12-bit: 0-4095)
    int batAdc = analogRead(Pins::SENSOR_BATTERY);
    int waterAdc = analogRead(Pins::SENSOR_WATER_LVL);
    int soapAdc = analogRead(Pins::SENSOR_SOAP_LVL);
    int tempAdc = analogRead(Pins::SENSOR_OBSTACLE); // Reusing pin for demo if temp not assigned

    // Map ADC to usable percentages/values (Calibration placeholders)
    // Battery: Assume voltage divider mapped 0-14V -> 0-4095
    _batteryVoltage = (batAdc / 4095.0f) * 14.0f;
    _batteryLevel = map(batAdc, 3000, 4095, 0, 100); 
    if (_batteryLevel < 0) _batteryLevel = 0;
    if (_batteryLevel > 100) _batteryLevel = 100;

    _waterLevel = map(waterAdc, 0, 4095, 0, 100);
    _soapLevel = map(soapAdc, 0, 4095, 0, 100);
    
    // Simulate Obstacle for now, or map real IR ADC
    _obstacleDistance = map(analogRead(Pins::SENSOR_OBSTACLE), 0, 4095, 10, 200);

    // Motor Temp simulation (as we didn't add a dedicated thermistor pin)
    // In closed loop, if motors are running, temp rises.
    if (millis() % 5000 < 10) {
        _motorTemp = 30 + (random(0, 10)); 
    }
}

int SensorManager::getBatteryLevel() { return _batteryLevel; }
int SensorManager::getWaterLevel() { return _waterLevel; }
int SensorManager::getSoapLevel() { return _soapLevel; }
int SensorManager::getMotorTemp() { return _motorTemp; }
int SensorManager::getObstacleDistance() { return _obstacleDistance; }
float SensorManager::getBatteryVoltage() { return _batteryVoltage; }
