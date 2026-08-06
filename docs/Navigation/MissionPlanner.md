# Mission Planner

The Mission Planner is the top-level orchestration engine for the SmartStall robot. It coordinates complex sequences across multiple hardware subsystems.

## Responsibilities
- Queueing waypoints (e.g., Clean Toilet 1 -> Clean Toilet 2 -> Dock).
- Issuing commands to the `NavigationController`.
- Waiting for Arrival (`NAV_ARRIVED`).
- Issuing commands to the `CleaningController`.
- Waiting for Cleaning completion (`STATE_COMPLETED`).
- Moving to the next item in the queue.

## Queue System
The mission queue holds up to 10 sequential Waypoint IDs. When the queue is exhausted, the state transitions to `MISSION_COMPLETED`.
