#ifndef MISSION_PLANNER_H
#define MISSION_PLANNER_H

#include "WaypointManager.h"
#include <Arduino.h>

enum MissionState {
    MISSION_IDLE,
    MISSION_PLANNING,
    MISSION_NAVIGATING,
    MISSION_ALIGNING,
    MISSION_CLEANING,
    MISSION_RETURNING,
    MISSION_COMPLETED,
    MISSION_PAUSED,
    MISSION_ERROR,
    MISSION_EMERGENCY
};

class MissionPlanner {
private:
    static MissionState currentState;
    static MissionState previousState;
    static int missionQueue[10];
    static int queueSize;
    static int currentQueueIndex;
    static unsigned long missionStartTime;
    static int totalMissionsCompleted;

public:
    static void init();
    static void startMission(int* waypoints, int count);
    static void pauseMission();
    static void resumeMission();
    static void cancelMission();
    static void tick();

    static MissionState getState() { return currentState; }
    static String getStateName();
    static int getCurrentWaypointId();
    static int getTargetWaypointId();
    static int getNavigationProgress();
    static unsigned long getMissionTime();
    static int getMissionCount();
};

#endif
