#ifndef ARUCO_DETECTOR_H
#define ARUCO_DETECTOR_H

#include <Arduino.h>

struct ArucoDetection {
    int markerId;
    float centerX;
    float centerY;
    float confidence;
    unsigned long timestamp;
    bool isValid;
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
