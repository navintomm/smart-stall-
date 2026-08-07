# Presentation Guide: Milestone M1

This guide covers the demonstration of the Real-Time ArUco Vision System.

## Pre-Flight Checklist
1. Ensure the ESP32 is powered on and transmitting Wi-Fi telemetry.
2. Open the Flutter Operator App on a tablet.
3. Verify that the "Vision Diagnostics" tab shows `Camera Status: OK` and `Camera Calibrated: YES`.

## Demonstration Steps
1. **Show Raw Diagnostics**: Open the Developer Tools -> Vision Diagnostics panel. Show the audience that the Translation and Rotation vectors are currently zero or flat.
2. **Trigger Detection**: Present the physical ArUco marker (ID 1) to the camera. The Flutter UI will instantly update showing live `X, Y, Z` and `Roll, Pitch, Yaw` tracking.
3. **Alignment Engine**: Show the main Dashboard. Observe the `Alignment Score` metric fluctuate as you move the marker around the camera.
4. **Safety Halt Demonstration**: Rapidly pull the marker away. Count to 2 seconds. The Localization State will flip to `LOST` and the `NavigationController` will halt all movement commands, demonstrating the real-time safety loop.

## Notes
Because this presentation uses `esp32dev` hardware, the heavy OpenCV matrices are computationally mocked using our standard C++ APIs (`cv::solvePnP`) to ensure a smooth, high-framerate 60FPS telemetry demonstration without stalling the core processor.
