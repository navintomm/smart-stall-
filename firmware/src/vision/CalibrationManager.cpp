#include "vision/CalibrationManager.h"

bool CalibrationManager::_calibrated = false;
cv::Mat CalibrationManager::_cameraMatrix;
cv::Mat CalibrationManager::_distCoeffs;
float CalibrationManager::_reprojectionError = 0.0f;

void CalibrationManager::init() {
    loadCalibration();
}

bool CalibrationManager::isCalibrated() {
    return _calibrated;
}

void CalibrationManager::loadCalibration() {
    // In a real environment, load from SPIFFS/EEPROM. 
    // Here we initialize standard matrices.
    
    _cameraMatrix = cv::Mat::eye(3, 3, CV_64F);
    _cameraMatrix.at<double>(0, 0, 800.0); // fx
    _cameraMatrix.at<double>(1, 1, 800.0); // fy
    _cameraMatrix.at<double>(0, 2, 320.0); // cx
    _cameraMatrix.at<double>(1, 2, 240.0); // cy
    
    _distCoeffs = cv::Mat::zeros(5, 1, CV_64F);
    
    _reprojectionError = 0.15f; // simulated valid error
    _calibrated = true;
}

cv::Mat CalibrationManager::getCameraMatrix() { return _cameraMatrix; }
cv::Mat CalibrationManager::getDistortionCoefficients() { return _distCoeffs; }
float CalibrationManager::getReprojectionError() { return _reprojectionError; }
