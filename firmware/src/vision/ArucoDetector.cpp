#include "vision/ArucoDetector.h"
#include "vision/CameraManager.h"
#include "vision/MarkerRegistry.h"

ArucoDetection ArucoDetector::_lastDetection = {0, 0.0f, 0.0f, 0.0f, 0, false};

void ArucoDetector::init() {
    _lastDetection.isValid = false;
}

void ArucoDetector::processFrame() {
    if (!CameraManager::acquireFrame()) return;

    // Simulate OpenCV ArUco detection based on time
    unsigned long currentMillis = millis();
    
    // Simulate detecting a Western Toilet marker (ID 1) every cycle for this mock
    if (currentMillis % 100 < 50) { // 50% detection rate simulated
        _lastDetection.markerId = 1;
        _lastDetection.centerX = 320.0f; // Mock 640x480 center
        _lastDetection.centerY = 240.0f;
        _lastDetection.confidence = 0.98f;
        _lastDetection.timestamp = currentMillis;
        
        // Ignore unknown markers
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
