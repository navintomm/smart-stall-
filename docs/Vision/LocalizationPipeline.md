# Localization Pipeline

```mermaid
graph TD;
    Camera[Camera Frame] --> Aruco[ArucoDetector]
    Aruco -->|Corners & ID| Pose[PoseEstimator]
    Pose -->|solvePnP| Alignment[AlignmentEngine]
    Alignment -->|Error & Score| LocState[LocalizationEngine]
    LocState --> Safety{Is Marker Lost?}
    Safety -- Yes --> Halt[Stop Robot]
    Safety -- No --> Telemetry[TelemetryEngine]
    Telemetry --> Flutter[Dashboard UI]
```

## State Machine
1. **SEARCHING**: Panning camera or robot body to find marker.
2. **ALIGNMENT_REQUIRED**: Marker detected, but alignment score < 90%.
3. **READY**: Marker is centered, distance is correct, yaw is 0.
4. **LOST**: Safety state triggered if marker disappears for > 2000ms.
