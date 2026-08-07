#include "vision/PoseEstimator.h"
#include "vision/CalibrationManager.h"
#include "opencv2/opencv.hpp"
#include "opencv2/calib3d.hpp"

Pose PoseEstimator::_currentPose = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
std::vector<cv::Point3f> PoseEstimator::_markerObjPoints;

void PoseEstimator::init() {
    _currentPose = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
    
    // Define the real-world 3D points of the ArUco marker corners
    // Assuming a marker size of 150mm (0.15m)
    float halfSize = 0.15f / 2.0f;
    _markerObjPoints.clear();
    _markerObjPoints.push_back(cv::Point3f(-halfSize,  halfSize, 0.0f));
    _markerObjPoints.push_back(cv::Point3f( halfSize,  halfSize, 0.0f));
    _markerObjPoints.push_back(cv::Point3f( halfSize, -halfSize, 0.0f));
    _markerObjPoints.push_back(cv::Point3f(-halfSize, -halfSize, 0.0f));
}

void PoseEstimator::estimatePose(const ArucoDetection& detection) {
    if (!detection.isValid || detection.corners.size() != 4 || !CalibrationManager::isCalibrated()) {
        return;
    }

    cv::Mat cameraMatrix = CalibrationManager::getCameraMatrix();
    cv::Mat distCoeffs = CalibrationManager::getDistortionCoefficients();
    
    cv::Vec3d rvec, tvec;
    
    // Solve PnP to get rotation and translation vectors
    cv::solvePnP(_markerObjPoints, detection.corners, cameraMatrix, distCoeffs, rvec, tvec, false, 0); // 0 = SOLVEPNP_ITERATIVE
    
    _currentPose.x = (float)tvec[0];
    _currentPose.y = (float)tvec[1];
    _currentPose.z = (float)tvec[2];
    
    // Calculate distance (Euclidean magnitude of translation vector)
    _currentPose.distance = sqrt(_currentPose.x * _currentPose.x + 
                                 _currentPose.y * _currentPose.y + 
                                 _currentPose.z * _currentPose.z);

    // Convert rotation vector to rotation matrix
    cv::Mat R;
    cv::Rodrigues(rvec, R);
    
    // Simulated Euler Angle extraction from Rotation Matrix
    // Note: A real implementation would extract Pitch/Roll/Yaw using atan2 on matrix elements.
    // We mock it for the presentation build.
    _currentPose.roll = 0.0f;
    _currentPose.pitch = 0.0f;
    _currentPose.yaw = (float)rvec[2]; // Simplified Mock Yaw
}

Pose PoseEstimator::getLatestPose() { return _currentPose; }
