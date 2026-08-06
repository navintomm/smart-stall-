# Alignment Engine

The Alignment Engine evaluates how close the robot is to the target pose.

## Metrics Calculated
- **Horizontal Offset (X):** Left/Right deviation.
- **Vertical Offset (Y):** Up/Down deviation (mostly ignored for ground robots).
- **Distance Error (Z):** Forward/Backward deviation from target cleaning range (e.g., 0.5m).
- **Rotation Offset (Yaw):** Angle deviation relative to the marker face.

## Score Calculation
Alignment Score is a percentage `[0-100]` derived from the magnitude of the combined errors.
```cpp
float errorMagnitude = abs(x) + abs(yaw) + abs(distError);
score = 100 - (errorMagnitude * 10);
```
A score > 95% indicates perfect alignment.
