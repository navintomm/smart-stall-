#include "vision/AlignmentEngine.h"

AlignmentData AlignmentEngine::_currentAlignment = {0.0f, 0.0f, 0.0f, 0.0f, 0};

void AlignmentEngine::calculateAlignment(const Pose& currentPose) {
    // Simulated alignment error calculation
    _currentAlignment.horizontalOffset = currentPose.x;
    _currentAlignment.verticalOffset = currentPose.y;
    _currentAlignment.rotationOffset = currentPose.yaw;
    _currentAlignment.distanceError = currentPose.distance - 0.5f; // Target 0.5m
    
    // Fake alignment score mapping
    float errorMagnitude = abs(_currentAlignment.horizontalOffset) + abs(_currentAlignment.rotationOffset) + abs(_currentAlignment.distanceError);
    _currentAlignment.alignmentScore = 100 - (int)(errorMagnitude * 10);
    if (_currentAlignment.alignmentScore < 0) _currentAlignment.alignmentScore = 0;
    if (_currentAlignment.alignmentScore > 100) _currentAlignment.alignmentScore = 100;
}

AlignmentData AlignmentEngine::getAlignment() { return _currentAlignment; }

bool AlignmentEngine::isAligned() { return _currentAlignment.alignmentScore > 95; }
