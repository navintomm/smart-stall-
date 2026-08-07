# ArUco Detection

## Pipeline (Python)
The ESP32 does not process video frames directly. Instead, the companion Python script handles video capture and detection using OpenCV's `aruco` module.

1. **Grayscale Conversion**: `cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)`.
2. **Detection**: `cv2.aruco.detectMarkers()` extracts square contours and matches them against `DICT_4X4_50`.
3. **Telemetry Push**: Upon successful detection, the Python script packages the Marker ID and confidence into a JSON payload and transmits it to the ESP32.

## Firmware Implementation
The ESP32 `ArucoDetector` class is now a lightweight state-holder. It simply exposes a `setDetection(id, confidence)` method that the `CommandDispatcher` calls whenever a `VISION_TELEMETRY` packet arrives over Wi-Fi.
