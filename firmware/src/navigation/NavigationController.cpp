#include "navigation/NavigationController.h"
#include "hardware/MotorController.h"
#include "vision/LocalizationEngine.h"
#include "vision/AlignmentEngine.h"
#include "vision/PoseEstimator.h"
#include "Logger.h"

NavigationState NavigationController::currentState = NAV_IDLE;
Waypoint NavigationController::targetWaypoint = {-1, "None", -1, 0, 0, 0};
unsigned long NavigationController::stateStartTime = 0;
unsigned long NavigationController::lastMoveTime = 0;
float NavigationController::distanceRemaining = 0.0;

void NavigationController::init() {
    currentState = NAV_IDLE;
}

void NavigationController::setTarget(Waypoint wp) {
    if (wp.id == -1) {
        Logger::error("NavControl", "Invalid target waypoint.");
        currentState = NAV_ERROR;
        return;
    }
    targetWaypoint = wp;
    currentState = NAV_SEARCHING;
    stateStartTime = millis();
    Logger::info("NavControl", "Target set to: " + wp.zoneName);
}

void NavigationController::stop() {
    MotorController::stop();
    currentState = NAV_IDLE;
    targetWaypoint = {-1, "None", -1, 0, 0, 0};
}

void NavigationController::pause() {
    if (currentState != NAV_IDLE && currentState != NAV_ARRIVED) {
        MotorController::stop();
        // Keep state, handled by planner
    }
}

void NavigationController::resume() {
    // Handled by tick
}

void NavigationController::tick() {
    if (currentState == NAV_IDLE || currentState == NAV_ERROR || currentState == NAV_ARRIVED) return;

    unsigned long currentMillis = millis();

    // Safety timeout
    if (currentMillis - stateStartTime > 60000) {
        Logger::error("NavControl", "Navigation timeout. Setting ERROR.");
        MotorController::stop();
        currentState = NAV_ERROR;
        return;
    }

    int detectedMarker = LocalizationEngine::getMarkerId();
    LocState locState = LocalizationEngine::getState();
    AlignmentData align = AlignmentEngine::getAlignment();
    Pose pose = PoseEstimator::getLatestPose();

    if (locState == LOC_LOST || locState == LOC_ERROR) {
        if (currentState != NAV_SEARCHING) {
            Logger::warning("NavControl", "Marker lost during navigation.");
            MotorController::stop();
            currentState = NAV_LOST;
        }
    } else if (locState == LOC_READY || locState == LOC_ALIGNMENT_REQUIRED) {
        if (detectedMarker == targetWaypoint.targetMarkerId) {
            distanceRemaining = pose.distance - targetWaypoint.tolerance;
            
            if (distanceRemaining <= 0 && align.alignmentScore > 90) {
                MotorController::stop();
                currentState = NAV_ARRIVED;
                Logger::info("NavControl", "Arrived at target: " + targetWaypoint.zoneName);
            } else if (align.alignmentScore < 70) {
                currentState = NAV_ALIGNING;
                if (pose.x > 0.1) MotorController::turnRight(40);
                else if (pose.x < -0.1) MotorController::turnLeft(40);
            } else {
                currentState = NAV_APPROACHING;
                if (distanceRemaining > 0) MotorController::moveForward(50);
                else MotorController::moveBackward(50);
            }
        } else {
            // Seeing wrong marker, keep searching/turning
            currentState = NAV_SEARCHING;
            MotorController::turnLeft(45);
        }
    }

    if (currentState == NAV_SEARCHING || currentState == NAV_LOST) {
        // Mock searching behavior: rotate slowly
        if (currentMillis - lastMoveTime > 1000) {
            MotorController::turnLeft(40);
            lastMoveTime = currentMillis;
            distanceRemaining = 5.0; // dummy distance
        }
    }
}

String NavigationController::getStateName() {
    switch (currentState) {
        case NAV_IDLE: return "IDLE";
        case NAV_SEARCHING: return "SEARCHING";
        case NAV_APPROACHING: return "APPROACHING";
        case NAV_ALIGNING: return "ALIGNING";
        case NAV_ARRIVED: return "ARRIVED";
        case NAV_LOST: return "LOST";
        case NAV_ERROR: return "ERROR";
        default: return "UNKNOWN";
    }
}
