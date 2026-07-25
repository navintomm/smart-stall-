#ifndef SENSOR_MANAGER_H
#define SENSOR_MANAGER_H

class SensorManager {
public:
    static void init();
    static void update();

    static int getBatteryLevel();
    static int getWaterLevel();
    static int getSoapLevel();
    static int getMotorTemp();

private:
    static int _batteryLevel;
    static int _waterLevel;
    static int _soapLevel;
    static int _motorTemp;
};

#endif // SENSOR_MANAGER_H
