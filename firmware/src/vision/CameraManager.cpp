#include "vision/CameraManager.h"

bool CameraManager::_healthy = false;
int CameraManager::_fps = 0;
unsigned long CameraManager::_lastFrameTime = 0;
int CameraManager::_frameCount = 0;
unsigned long CameraManager::_fpsCalculateTime = 0;

void CameraManager::init() {
    _healthy = true;
    _fps = 0;
    _lastFrameTime = millis();
    _frameCount = 0;
    _fpsCalculateTime = millis();
}

void CameraManager::tick() {
    if (millis() - _fpsCalculateTime >= 1000) {
        _fps = _frameCount;
        _frameCount = 0;
        _fpsCalculateTime = millis();
    }
}

bool CameraManager::acquireFrame() {
    if (!_healthy) return false;
    _lastFrameTime = millis();
    _frameCount++;
    return true; // Simulated successful frame capture
}

int CameraManager::getFPS() { return _fps; }
bool CameraManager::isHealthy() { return _healthy; }
unsigned long CameraManager::getLastFrameTimestamp() { return _lastFrameTime; }
