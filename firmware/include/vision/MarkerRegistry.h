#ifndef MARKER_REGISTRY_H
#define MARKER_REGISTRY_H

#include <Arduino.h>

enum MarkerType {
    MARKER_UNKNOWN = 0,
    MARKER_WESTERN_TOILET = 1,
    MARKER_INDIAN_TOILET = 2,
    MARKER_URINAL = 3,
    MARKER_DOCKING_STATION = 10,
    MARKER_MAINTENANCE_AREA = 20
};

class MarkerRegistry {
public:
    static MarkerType getMarkerType(int markerId);
    static String getMarkerName(MarkerType type);
};

#endif
