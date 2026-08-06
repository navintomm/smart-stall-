# Camera Calibration

Camera calibration is essential for accurate Pose Estimation (solvePnP).

## Parameters
The `CalibrationManager` stores:
- **Camera Matrix:** $3 \times 3$ intrinsic parameter matrix $(f_x, f_y, c_x, c_y)$.
- **Distortion Coefficients:** Radial and tangential distortion vectors $(k_1, k_2, p_1, p_2, k_3)$.

## Calibration Process
1. Print a standard OpenCV checkerboard pattern.
2. Capture at least 15-20 images from various angles.
3. Run calibration script (offline) to generate parameters.
4. Flash the parameters to the ESP32 SPIFFS or hardcode in `CalibrationManager`.
