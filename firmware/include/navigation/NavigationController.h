#ifndef NAVIGATION_CONTROLLER_H
#define NAVIGATION_CONTROLLER_H

#include "WaypointManager.h"
#include <Arduino.h>

enum NavigationState {
    NAV_IDLE,
    NAV_SEARCHING,
    NAV_APPROACHING,
    NAV_ALIGNING,
    NAV_ARRIVED,
    NAV_LOST,
    NAV_ERROR
};

class NavigationController {
private:
    static NavigationState currentState;
    static Waypoint targetWaypoint;
    static unsigned long stateStartTime;
    static unsigned long lastMoveTime;
    static float distanceRemaining;

public:
    static void init();
    static void setTarget(Waypoint wp);
    static void stop();
    static void pause();
    static void resume();
    static void tick();
    
    static NavigationState getState() { return currentState; }
    static String getStateName();
    static Waypoint getTarget() { return targetWaypoint; }
    static float getDistanceRemaining() { return distanceRemaining; }
};

#endif
