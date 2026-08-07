#ifndef ARUCO_DETECTOR_H
#define ARUCO_DETECTOR_H

#include <Arduino.h>
#include "opencv2/opencv.hpp"
#include <vector>

struct ArucoDetection {
    int markerId;
    float centerX;
    float centerY;
    float confidence;
    unsigned long timestamp;
    bool isValid;
    std::vector<cv::Point2f> corners; // Needed for solvePnP
};

class ArucoDetector {
public:
    static void init();
    static void processFrame();
    static ArucoDetection getLatestDetection();

private:
    static ArucoDetection _lastDetection;
};

#endif
