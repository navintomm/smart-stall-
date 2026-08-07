#include "vision/ArucoDetector.h"
#include "vision/MarkerRegistry.h"

ArucoDetection ArucoDetector::_lastDetection;

void ArucoDetector::init() {
    _lastDetection.isValid = false;
}

void ArucoDetector::processFrame() {
    // OpenCV detection is now handled by external Python Vision Processor.
    // We no longer simulate detections here.
}

void ArucoDetector::setDetection(int markerId, float confidence) {
    if (MarkerRegistry::getMarkerType(markerId) != MARKER_UNKNOWN) {
        _lastDetection.markerId = markerId;
        _lastDetection.confidence = confidence;
        _lastDetection.timestamp = millis();
        _lastDetection.isValid = true;
    } else {
        _lastDetection.isValid = false;
    }
}

ArucoDetection ArucoDetector::getLatestDetection() { return _lastDetection; }
