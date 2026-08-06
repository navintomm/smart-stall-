#include "vision/CalibrationManager.h"

bool CalibrationManager::_calibrated = false;

void CalibrationManager::init() {
    loadCalibration();
}

bool CalibrationManager::isCalibrated() {
    return _calibrated;
}

void CalibrationManager::loadCalibration() {
    // Simulate loading camera matrix and distortion coefficients
    _calibrated = true;
}
