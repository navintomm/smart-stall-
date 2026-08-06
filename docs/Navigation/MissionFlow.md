# Mission Flow

This documents the state transitions for the Mission Planner.

## Normal Flow
```text
MISSION_IDLE -> MISSION_PLANNING
MISSION_PLANNING -> MISSION_NAVIGATING
MISSION_NAVIGATING <-> MISSION_ALIGNING
(Arrival at target) -> MISSION_CLEANING
(Cleaning finished) -> MISSION_PLANNING (Next waypoint)
(Queue empty) -> MISSION_COMPLETED
```

## Pausing Flow
If the user sends `MISSION_PAUSE` (Command 602):
- Any active navigation pauses (motors stop).
- Any active cleaning pauses (pumps/brushes stop).
- State becomes `MISSION_PAUSED`.
- `MISSION_RESUME` restores the previous state.
