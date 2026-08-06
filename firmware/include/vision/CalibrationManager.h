#ifndef CALIBRATION_MANAGER_H
#define CALIBRATION_MANAGER_H

#include <Arduino.h>

class CalibrationManager {
public:
    static void init();
    static bool isCalibrated();
    static void loadCalibration();

private:
    static bool _calibrated;
};

#endif
