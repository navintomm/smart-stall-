#include "navigation/MissionPlanner.h"
#include "navigation/NavigationController.h"
#include "hardware/CleaningController.h"
#include "hardware/EmergencyController.h"
#include "RobotState.h"
#include "Logger.h"

MissionState MissionPlanner::currentState = MISSION_IDLE;
MissionState MissionPlanner::previousState = MISSION_IDLE;
int MissionPlanner::missionQueue[10];
int MissionPlanner::queueSize = 0;
int MissionPlanner::currentQueueIndex = 0;
unsigned long MissionPlanner::missionStartTime = 0;
int MissionPlanner::totalMissionsCompleted = 0;

void MissionPlanner::init() {
    WaypointManager::init();
    NavigationController::init();
    currentState = MISSION_IDLE;
}

void MissionPlanner::startMission(int* waypoints, int count) {
    if (currentState != MISSION_IDLE && currentState != MISSION_COMPLETED && currentState != MISSION_ERROR) {
        Logger::warning("MissionPlanner", "Cannot start mission. Busy.");
        return;
    }
    
    if (count == 0 || count > 10) return;

    for (int i = 0; i < count; i++) {
        missionQueue[i] = waypoints[i];
    }
    queueSize = count;
    currentQueueIndex = 0;
    missionStartTime = millis();
    
    currentState = MISSION_PLANNING;
    Logger::info("MissionPlanner", "Mission Started.");
}

void MissionPlanner::pauseMission() {
    if (currentState == MISSION_NAVIGATING || currentState == MISSION_ALIGNING || currentState == MISSION_CLEANING || currentState == MISSION_RETURNING) {
        previousState = currentState;
        currentState = MISSION_PAUSED;
        NavigationController::pause();
        CleaningController::pause();
        Logger::info("MissionPlanner", "Mission Paused.");
    }
}

void MissionPlanner::resumeMission() {
    if (currentState == MISSION_PAUSED) {
        currentState = previousState;
        NavigationController::resume();
        if (currentState == MISSION_CLEANING) CleaningController::resume();
        Logger::info("MissionPlanner", "Mission Resumed.");
    }
}

void MissionPlanner::cancelMission() {
    NavigationController::stop();
    CleaningController::stop();
    currentState = MISSION_IDLE;
    queueSize = 0;
    currentQueueIndex = 0;
    Logger::info("MissionPlanner", "Mission Cancelled.");
}

void MissionPlanner::tick() {
    if (EmergencyController::isEmergency()) {
        if (currentState != MISSION_EMERGENCY) {
            previousState = currentState;
            currentState = MISSION_EMERGENCY;
            NavigationController::stop();
            CleaningController::pause();
        }
        return;
    } else if (currentState == MISSION_EMERGENCY) {
        currentState = MISSION_PAUSED; // Require manual resume after emergency
    }

    if (currentState == MISSION_IDLE || currentState == MISSION_PAUSED || currentState == MISSION_COMPLETED || currentState == MISSION_ERROR) {
        return; // Nothing to do
    }

    int currentTargetId = missionQueue[currentQueueIndex];
    Waypoint targetWp = WaypointManager::getWaypointById(currentTargetId);

    switch(currentState) {
        case MISSION_PLANNING:
            if (targetWp.id != -1) {
                NavigationController::setTarget(targetWp);
                currentState = MISSION_NAVIGATING;
            } else {
                currentState = MISSION_ERROR;
            }
            break;

        case MISSION_NAVIGATING:
        case MISSION_ALIGNING:
        case MISSION_RETURNING:
            NavigationController::tick();
            
            if (NavigationController::getState() == NAV_ALIGNING) {
                currentState = MISSION_ALIGNING;
            } else if (NavigationController::getState() == NAV_ARRIVED) {
                if (targetWp.targetMarkerId == 10 || targetWp.targetMarkerId == 20) {
                    // Dock or maintenance, no cleaning
                    currentQueueIndex++;
                    if (currentQueueIndex >= queueSize) {
                        currentState = MISSION_COMPLETED;
                        totalMissionsCompleted++;
                        Logger::info("MissionPlanner", "Mission Completed.");
                    } else {
                        currentState = MISSION_PLANNING;
                    }
                } else {
                    // It's a cleaning target
                    CleaningController::start();
                    if (CleaningController::getState() == STATE_ERROR) {
                        currentState = MISSION_ERROR;
                    } else {
                        currentState = MISSION_CLEANING;
                    }
                }
            } else if (NavigationController::getState() == NAV_ERROR) {
                currentState = MISSION_ERROR;
            }
            break;

        case MISSION_CLEANING:
            if (CleaningController::getState() == STATE_COMPLETED) {
                currentQueueIndex++;
                if (currentQueueIndex >= queueSize) {
                    currentState = MISSION_COMPLETED;
                    totalMissionsCompleted++;
                    Logger::info("MissionPlanner", "Mission Completed.");
                } else {
                    currentState = MISSION_PLANNING;
                }
            } else if (CleaningController::getState() == STATE_ERROR) {
                currentState = MISSION_ERROR;
            }
            break;
            
        default:
            break;
    }
}

String MissionPlanner::getStateName() {
    switch(currentState) {
        case MISSION_IDLE: return "IDLE";
        case MISSION_PLANNING: return "PLANNING";
        case MISSION_NAVIGATING: return "NAVIGATING";
        case MISSION_ALIGNING: return "ALIGNING";
        case MISSION_CLEANING: return "CLEANING";
        case MISSION_RETURNING: return "RETURNING";
        case MISSION_COMPLETED: return "COMPLETED";
        case MISSION_PAUSED: return "PAUSED";
        case MISSION_ERROR: return "ERROR";
        case MISSION_EMERGENCY: return "EMERGENCY";
        default: return "UNKNOWN";
    }
}

int MissionPlanner::getCurrentWaypointId() {
    if (currentQueueIndex > 0 && currentQueueIndex <= queueSize) {
        return missionQueue[currentQueueIndex - 1];
    }
    return -1;
}

int MissionPlanner::getTargetWaypointId() {
    if (currentQueueIndex < queueSize) {
        return missionQueue[currentQueueIndex];
    }
    return -1;
}

int MissionPlanner::getNavigationProgress() {
    if (queueSize == 0) return 0;
    return (currentQueueIndex * 100) / queueSize;
}

unsigned long MissionPlanner::getMissionTime() {
    if (currentState == MISSION_IDLE || missionStartTime == 0) return 0;
    return (millis() - missionStartTime) / 1000;
}

int MissionPlanner::getMissionCount() {
    return totalMissionsCompleted;
}
