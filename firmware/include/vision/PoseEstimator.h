#ifndef POSE_ESTIMATOR_H
#define POSE_ESTIMATOR_H

#include <Arduino.h>
#include "ArucoDetector.h"

struct Pose {
    float x;
    float y;
    float z;
    float roll;
    float pitch;
    float yaw;
    float distance;
};

class PoseEstimator {
public:
    static void init();
    static void estimatePose(const ArucoDetection& detection);
    static Pose getLatestPose();

private:
    static Pose _currentPose;
};

#endif
