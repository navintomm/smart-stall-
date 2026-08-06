# Telemetry Specification Updates

The telemetry payload has been extended to support real-time UI updates for Mission Control.

## New Fields
| Field Name | Type | Description |
|------------|------|-------------|
| `mission_state` | String | Current MissionPlanner state (e.g., `NAVIGATING`) |
| `nav_state` | String | Current NavigationController state (e.g., `ALIGNING`) |
| `current_waypoint` | Int | ID of the previously completed waypoint |
| `target_waypoint` | Int | ID of the destination waypoint |
| `navigation_progress` | Int | Progress through the mission queue (0-100) |
| `distance_remaining` | Float | Distance left to the target marker in meters |
| `mission_time` | Int | Elapsed time since the mission started in seconds |
| `mission_count` | Int | Total number of missions completed |
