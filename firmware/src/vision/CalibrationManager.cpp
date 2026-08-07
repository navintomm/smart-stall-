#include "vision/CalibrationManager.h"

bool CalibrationManager::_calibrated = false;

void CalibrationManager::init() {
    _calibrated = false; // Set externally by Python Vision Processor
}

bool CalibrationManager::isCalibrated() {
    return _calibrated;
}

void CalibrationManager::setCalibrated(bool calibrated) {
    _calibrated = calibrated;
}
