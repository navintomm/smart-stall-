#include "vision/AlignmentEngine.h"
#include <math.h>

AlignmentData AlignmentEngine::_currentAlignment = {0.0f, 0.0f, 0.0f, 0.0f, 0};

void AlignmentEngine::calculateAlignment(const Pose& currentPose) {
    // Real alignment error calculation
    _currentAlignment.horizontalOffset = currentPose.x; // Target is 0 (centered)
    _currentAlignment.verticalOffset = currentPose.y;   // Target is 0
    _currentAlignment.rotationOffset = currentPose.yaw; // Target is 0 (facing directly)
    _currentAlignment.distanceError = currentPose.distance - 0.5f; // Target is 0.5m away
    
    // Calculate a strict alignment score (0-100)
    // Assuming max acceptable errors before score hits 0:
    // Max horiz: 0.2m, Max rot: 0.3 rad, Max dist: 0.3m
    float maxHorizError = 0.2f;
    float maxRotError = 0.3f;
    float maxDistError = 0.3f;
    
    float horizPenalty = (abs(_currentAlignment.horizontalOffset) / maxHorizError) * 33.3f;
    float rotPenalty = (abs(_currentAlignment.rotationOffset) / maxRotError) * 33.3f;
    float distPenalty = (abs(_currentAlignment.distanceError) / maxDistError) * 33.3f;
    
    float totalPenalty = horizPenalty + rotPenalty + distPenalty;
    
    _currentAlignment.alignmentScore = 100 - (int)totalPenalty;
    if (_currentAlignment.alignmentScore < 0) _currentAlignment.alignmentScore = 0;
    if (_currentAlignment.alignmentScore > 100) _currentAlignment.alignmentScore = 100;
}

AlignmentData AlignmentEngine::getAlignment() { return _currentAlignment; }

bool AlignmentEngine::isAligned() { return _currentAlignment.alignmentScore > 90; }
