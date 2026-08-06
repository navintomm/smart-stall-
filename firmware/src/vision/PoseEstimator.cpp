#include "vision/PoseEstimator.h"

Pose PoseEstimator::_currentPose = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};

void PoseEstimator::init() {
    _currentPose = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
}

void PoseEstimator::estimatePose(const ArucoDetection& detection) {
    if (!detection.isValid) return;

    // Simulated pose estimation math (cv::solvePnP mock)
    // In a real scenario, this would use camera matrix and obj/img points.
    _currentPose.x = 0.0f; 
    _currentPose.y = 0.0f; 
    _currentPose.z = 1.0f; // 1 meter away
    
    _currentPose.roll = 0.0f;
    _currentPose.pitch = 0.0f;
    _currentPose.yaw = 0.0f;
    
    _currentPose.distance = 1.0f;
}

Pose PoseEstimator::getLatestPose() { return _currentPose; }
