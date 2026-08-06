#include "vision/LocalizationEngine.h"
#include "vision/CameraManager.h"
#include "vision/ArucoDetector.h"
#include "vision/PoseEstimator.h"
#include "vision/AlignmentEngine.h"
#include "Logger.h"

LocalizationState LocalizationEngine::_currentState = LOC_SEARCHING;
int LocalizationEngine::_currentMarkerId = 0;
float LocalizationEngine::_confidence = 0.0f;
unsigned long LocalizationEngine::_lastDetectionTime = 0;

void LocalizationEngine::init() {
    CameraManager::init();
    ArucoDetector::init();
    PoseEstimator::init();
    _currentState = LOC_SEARCHING;
    _currentMarkerId = 0;
    _confidence = 0.0f;
}

void LocalizationEngine::tick() {
    CameraManager::tick();
    ArucoDetector::processFrame();
    
    ArucoDetection detection = ArucoDetector::getLatestDetection();
    
    if (detection.isValid) {
        if (_currentMarkerId != detection.markerId) {
            Logger::info("Localization", "Marker Detected: " + String(detection.markerId));
        }
        _currentMarkerId = detection.markerId;
        _confidence = detection.confidence;
        _lastDetectionTime = detection.timestamp;
        
        PoseEstimator::estimatePose(detection);
        AlignmentEngine::calculateAlignment(PoseEstimator::getLatestPose());
    }
    
    evaluateState();
}

void LocalizationEngine::evaluateState() {
    unsigned long elapsedSinceDetection = millis() - _lastDetectionTime;
    
    if (!CameraManager::isHealthy()) {
        _currentState = LOC_ERROR;
        return;
    }
    
    if (elapsedSinceDetection > 2000) {
        if (_currentState != LOC_LOST && _currentState != LOC_SEARCHING) {
            Logger::warning("Localization", "Marker Lost");
        }
        _currentState = LOC_LOST;
        _confidence = 0.0f;
    } else {
        if (AlignmentEngine::isAligned()) {
            if (_currentState != LOC_READY) {
                Logger::info("Localization", "Localization Ready");
            }
            _currentState = LOC_READY;
        } else {
            _currentState = LOC_ALIGNMENT_REQUIRED;
        }
    }
}

LocalizationState LocalizationEngine::getState() { return _currentState; }

String LocalizationEngine::getStateName() {
    switch (_currentState) {
        case LOC_SEARCHING: return "SEARCHING";
        case LOC_MARKER_DETECTED: return "MARKER_DETECTED";
        case LOC_ALIGNMENT_REQUIRED: return "ALIGNMENT_REQUIRED";
        case LOC_READY: return "READY";
        case LOC_LOST: return "LOST";
        case LOC_ERROR: return "ERROR";
        default: return "UNKNOWN";
    }
}

int LocalizationEngine::getMarkerId() { return _currentMarkerId; }
float LocalizationEngine::getConfidence() { return _confidence; }
unsigned long LocalizationEngine::getLastDetectionTime() { return _lastDetectionTime; }
