#include "navigation/WaypointManager.h"

Waypoint WaypointManager::waypoints[5];
int WaypointManager::waypointCount = 0;

void WaypointManager::init() {
    // Define predefined waypoints
    waypoints[0] = {100, "Docking Station", 10, 0.0, 0.0, 0.1};
    waypoints[1] = {101, "Zone A - Western", 1, 2.0, 2.0, 0.2};
    waypoints[2] = {102, "Zone B - Indian", 2, 4.0, 2.0, 0.2};
    waypoints[3] = {103, "Zone C - Urinal", 3, 6.0, 0.0, 0.2};
    waypoints[4] = {104, "Maintenance", 20, 0.0, -2.0, 0.5};
    waypointCount = 5;
}

Waypoint WaypointManager::getWaypointById(int id) {
    for (int i = 0; i < waypointCount; i++) {
        if (waypoints[i].id == id) {
            return waypoints[i];
        }
    }
    // Return empty invalid waypoint
    return {-1, "Unknown", -1, 0, 0, 0};
}

Waypoint WaypointManager::getWaypointByMarkerId(int markerId) {
    for (int i = 0; i < waypointCount; i++) {
        if (waypoints[i].targetMarkerId == markerId) {
            return waypoints[i];
        }
    }
    return {-1, "Unknown", -1, 0, 0, 0};
}

int WaypointManager::getWaypointCount() {
    return waypointCount;
}

Waypoint WaypointManager::getWaypointByIndex(int index) {
    if (index >= 0 && index < waypointCount) {
        return waypoints[index];
    }
    return {-1, "Unknown", -1, 0, 0, 0};
}
