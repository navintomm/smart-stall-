#ifndef ARUCO_DETECTOR_H
#define ARUCO_DETECTOR_H

#include <Arduino.h>

struct ArucoDetection {
    int markerId;
    float confidence;
    unsigned long timestamp;
    bool isValid;
};

class ArucoDetector {
public:
    static void init();
    static void processFrame(); // No-op now, handled by external Vision Processor
    static void setDetection(int markerId, float confidence);
    static ArucoDetection getLatestDetection();

private:
    static ArucoDetection _lastDetection;
};

#endif
