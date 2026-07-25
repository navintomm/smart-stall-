#ifndef ROBOT_STATE_H
#define ROBOT_STATE_H

#include <Arduino.h>

class RobotState {
public:
    static void init();
    static void update();

    static int getBatteryLevel();
    static int getWaterLevel();
    static int getSoapLevel();
    static int getMotorTemp();
    static const char* getMode();

    static void setMode(const char* newMode);

private:
    static int _batteryLevel;
    static int _waterLevel;
    static int _soapLevel;
    static int _motorTemp;
    static String _currentMode;
};

#endif // ROBOT_STATE_H
