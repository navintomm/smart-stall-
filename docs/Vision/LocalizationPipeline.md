# Localization Pipeline (External Vision Architecture)

```mermaid
graph TD;
    subgraph Companion Computer (Python)
        Camera[Webcam] --> Aruco[cv2.aruco]
        Aruco -->|Corners & ID| Pose[cv2.solvePnP]
        Pose -->|X,Y,Z,Yaw| TCPClient[TCP Socket Client]
    end

    subgraph ESP32 Firmware
        TCPServer[WifiServerHandler] -->|JSON Packet| CmdDispatcher[CommandDispatcher]
        CmdDispatcher -->|VISION_TELEMETRY| DataHolders[PoseEstimator / ArucoDetector]
        DataHolders --> LocState[LocalizationEngine]
        LocState --> Safety{Is Marker Lost?}
        Safety -- Yes --> Halt[Stop Robot]
        Safety -- No --> Telemetry[TelemetryEngine]
    end
    
    subgraph Operator Tablet
        Telemetry --> Flutter[Dashboard UI]
    end

    TCPClient -.->|Wi-Fi Port 8888| TCPServer
```

## State Machine (ESP32)
1. **SEARCHING**: Panning camera or robot body to find marker.
2. **ALIGNMENT_REQUIRED**: Marker detected via TCP, but alignment score < 90%.
3. **READY**: Marker is centered, distance is correct, yaw is 0.
4. **LOST**: Safety state triggered if TCP packets stop arriving or marker drops out of view for > 2000ms.
