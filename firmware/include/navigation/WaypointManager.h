#ifndef WAYPOINT_MANAGER_H
#define WAYPOINT_MANAGER_H

#include <Arduino.h>

struct Waypoint {
    int id;
    String zoneName;
    int targetMarkerId;
    float x;
    float y;
    float tolerance;
};

class WaypointManager {
private:
    static Waypoint waypoints[5];
    static int waypointCount;

public:
    static void init();
    static Waypoint getWaypointById(int id);
    static Waypoint getWaypointByMarkerId(int markerId);
    static int getWaypointCount();
    static Waypoint getWaypointByIndex(int index);
};

#endif
