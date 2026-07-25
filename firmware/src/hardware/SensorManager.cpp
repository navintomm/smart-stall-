#include "hardware/SensorManager.h"
#include "config/pin_map.h"
#include "Logger.h"
#include <Arduino.h>

int SensorManager::_batteryLevel = 100;
int SensorManager::_waterLevel = 100;
int SensorManager::_soapLevel = 100;
int SensorManager::_motorTemp = 25;

void SensorManager::init() {
    pinMode(Pins::SENSOR_WATER_LVL, INPUT);
    pinMode(Pins::SENSOR_SOAP_LVL, INPUT);
    pinMode(Pins::SENSOR_BATTERY, INPUT);
    Logger::info("HAL", "SensorManager initialized");
}

void SensorManager::update() {
    // In a physical implementation, we would read analogRead() and map it.
    // For now we simulate sensor drifting.
    if (millis() % 10000 < 10) { 
        if (_batteryLevel > 10) _batteryLevel--;
        _motorTemp = 30 + (millis() % 10);
    }
}

int SensorManager::getBatteryLevel() { return _batteryLevel; }
int SensorManager::getWaterLevel() { return _waterLevel; }
int SensorManager::getSoapLevel() { return _soapLevel; }
int SensorManager::getMotorTemp() { return _motorTemp; }
