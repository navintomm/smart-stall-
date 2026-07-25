#include "RobotState.h"

int RobotState::_batteryLevel = 100;
int RobotState::_waterLevel = 100;
int RobotState::_soapLevel = 100;
int RobotState::_motorTemp = 25;
String RobotState::_currentMode = "IDLE";

void RobotState::init() {
    _batteryLevel = 98;
    _waterLevel = 90;
    _soapLevel = 85;
    _motorTemp = 32;
    _currentMode = "IDLE";
}

void RobotState::update() {
    // In a real implementation, this reads from ADCs/Sensors.
    // For simulation, we slowly drift the values to simulate battery drain, etc.
    if (millis() % 10000 < 10) { 
        if (_batteryLevel > 10) _batteryLevel--;
        // Temp fluctuates
        _motorTemp = 30 + (millis() % 10);
    }
}

int RobotState::getBatteryLevel() { return _batteryLevel; }
int RobotState::getWaterLevel() { return _waterLevel; }
int RobotState::getSoapLevel() { return _soapLevel; }
int RobotState::getMotorTemp() { return _motorTemp; }
const char* RobotState::getMode() { return _currentMode.c_str(); }

void RobotState::setMode(const char* newMode) {
    _currentMode = newMode;
}
