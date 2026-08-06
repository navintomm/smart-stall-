#ifndef ALIGNMENT_ENGINE_H
#define ALIGNMENT_ENGINE_H

#include <Arduino.h>
#include "PoseEstimator.h"

struct AlignmentData {
    float horizontalOffset;
    float verticalOffset;
    float rotationOffset;
    float distanceError;
    int alignmentScore; // 0-100
};

class AlignmentEngine {
public:
    static void calculateAlignment(const Pose& currentPose);
    static AlignmentData getAlignment();
    static bool isAligned();

private:
    static AlignmentData _currentAlignment;
};

#endif
