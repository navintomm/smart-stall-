# Safety Logic

The Mission Planner integrates closely with the `EmergencyController` and physical safety limits.

## Emergency Interruptions
If `EmergencyController::isEmergency()` returns true (due to e-stop button or critical sensor thresholds):
1. The Mission Planner state is forced to `MISSION_EMERGENCY`.
2. `NavigationController::stop()` is called.
3. `CleaningController::pause()` is called.

## Recovery
When the emergency is cleared (Command 402):
1. State drops from `MISSION_EMERGENCY` to `MISSION_PAUSED`.
2. The mission does **not** auto-resume. The operator must explicitly send a Resume command (603) via the Dashboard.
