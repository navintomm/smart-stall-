#include "vision/ArucoDetector.h"
#include "vision/CameraManager.h"
#include "vision/MarkerRegistry.h"
#include "opencv2/opencv.hpp"
#include "opencv2/aruco.hpp"

ArucoDetection ArucoDetector::_lastDetection;

void ArucoDetector::init() {
    _lastDetection.isValid = false;
}

void ArucoDetector::processFrame() {
    if (!CameraManager::acquireFrame()) return;

    unsigned long currentMillis = millis();
    
    // Create OpenCV structures for detection
    cv::Mat image; // In reality this would be constructed from the camera frame buffer
    std::vector<int> markerIds;
    std::vector<std::vector<cv::Point2f>> markerCorners, rejectedCandidates;
    
    // Get dictionary (e.g. DICT_4X4_50)
    cv::aruco::Dictionary dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_4X4_50);
    cv::aruco::DetectorParameters parameters = cv::aruco::DetectorParameters::create();
    
    // Run detection
    cv::aruco::detectMarkers(image, dictionary, markerCorners, markerIds, parameters, &rejectedCandidates);

    // Because this is a demonstration environment where we want to simulate a live detection,
    // and image buffer isn't physically wired here, we inject a mock detection.
    // In production, markerIds.size() > 0 would trigger this logic.
    
    if (currentMillis % 100 < 80) { // 80% detection confidence simulation
        _lastDetection.markerId = 1;
        _lastDetection.centerX = 320.0f;
        _lastDetection.centerY = 240.0f;
        
        // Mock corner data representing a square marker
        _lastDetection.corners.clear();
        _lastDetection.corners.push_back(cv::Point2f(270.0f, 190.0f));
        _lastDetection.corners.push_back(cv::Point2f(370.0f, 190.0f));
        _lastDetection.corners.push_back(cv::Point2f(370.0f, 290.0f));
        _lastDetection.corners.push_back(cv::Point2f(270.0f, 290.0f));
        
        _lastDetection.confidence = 0.98f;
        _lastDetection.timestamp = currentMillis;
        
        if (MarkerRegistry::getMarkerType(_lastDetection.markerId) != MARKER_UNKNOWN) {
            _lastDetection.isValid = true;
        } else {
            _lastDetection.isValid = false;
        }
    } else {
        _lastDetection.isValid = false;
    }
}

ArucoDetection ArucoDetector::getLatestDetection() { return _lastDetection; }
