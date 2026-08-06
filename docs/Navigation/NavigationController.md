# Navigation Controller

The Navigation Controller connects the raw data of the `LocalizationEngine` to the `MotorController`. Since the robot lacks complex SLAM or path planning, it relies on deterministic behaviors.

## Behaviors
1. **Searching (`NAV_SEARCHING`):** Rotates slowly until the `LocalizationEngine` acquires the target `MarkerID`.
2. **Approaching (`NAV_APPROACHING`):** Moves forward or backward to achieve the correct distance offset (Z).
3. **Aligning (`NAV_ALIGNING`):** Rotates slightly left or right to correct horizontal deviation (X).
4. **Arrived (`NAV_ARRIVED`):** Alignment Score is >90% and Distance Remaining is 0.

## Error Recovery
If the `LocalizationEngine` reports `LOC_LOST` during movement, the motors stop, and the state becomes `NAV_LOST`. The robot will wait or resume searching depending on the mission planner context.
