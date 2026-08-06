#include "vision/MarkerRegistry.h"

MarkerType MarkerRegistry::getMarkerType(int markerId) {
    switch (markerId) {
        case 1: return MARKER_WESTERN_TOILET;
        case 2: return MARKER_INDIAN_TOILET;
        case 3: return MARKER_URINAL;
        case 10: return MARKER_DOCKING_STATION;
        case 20: return MARKER_MAINTENANCE_AREA;
        default: return MARKER_UNKNOWN;
    }
}

String MarkerRegistry::getMarkerName(MarkerType type) {
    switch (type) {
        case MARKER_WESTERN_TOILET: return "Western Toilet";
        case MARKER_INDIAN_TOILET: return "Indian Toilet";
        case MARKER_URINAL: return "Urinal";
        case MARKER_DOCKING_STATION: return "Docking Station";
        case MARKER_MAINTENANCE_AREA: return "Maintenance Area";
        default: return "Unknown";
    }
}
