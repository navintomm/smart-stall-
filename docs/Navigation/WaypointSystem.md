# Waypoint System

Waypoints are virtual locations the robot navigates to by relying on ArUco Markers.

## Structure
- **ID:** Unique identifier for the waypoint.
- **Zone Name:** Human-readable label (e.g., "Zone A - Western").
- **Target Marker ID:** The ArUco Marker ID to search for and align against.
- **X, Y:** Relative coordinates used primarily for drawing the schematic Navigation Map in the Flutter UI.
- **Tolerance:** Allowed error margin in meters when arriving at the marker.

## Predefined Waypoints
- ID 100: Docking Station (Marker 10)
- ID 101: Zone A (Marker 1)
- ID 102: Zone B (Marker 2)
- ID 103: Zone C (Marker 3)
- ID 104: Maintenance (Marker 20)
