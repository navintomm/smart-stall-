#ifndef CALIBRATION_MANAGER_H
#define CALIBRATION_MANAGER_H

#include <Arduino.h>
#include "opencv2/opencv.hpp"

class CalibrationManager {
public:
    static void init();
    static bool isCalibrated();
    static void loadCalibration();
    
    // Getters for OpenCV solvePnP
    static cv::Mat getCameraMatrix();
    static cv::Mat getDistortionCoefficients();
    
    static float getReprojectionError();

private:
    static bool _calibrated;
    static cv::Mat _cameraMatrix;
    static cv::Mat _distCoeffs;
    static float _reprojectionError;
};

#endif
