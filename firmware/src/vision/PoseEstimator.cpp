#include "vision/PoseEstimator.h"

Pose PoseEstimator::_currentPose = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};

void PoseEstimator::init() {
    _currentPose = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
}

void PoseEstimator::estimatePose(const ArucoDetection& detection) {
    // OpenCV solvePnP is now handled by external Python Vision Processor.
    // We no longer calculate pose here.
}

void PoseEstimator::setPose(float x, float y, float z, float roll, float pitch, float yaw, float distance) {
    _currentPose.x = x;
    _currentPose.y = y;
    _currentPose.z = z;
    _currentPose.roll = roll;
    _currentPose.pitch = pitch;
    _currentPose.yaw = yaw;
    _currentPose.distance = distance;
}

Pose PoseEstimator::getLatestPose() { return _currentPose; }
