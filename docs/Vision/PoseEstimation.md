# Pose Estimation

## cv2.solvePnP (Python)
Pose estimation uses `cv2.solvePnP` (Perspective-n-Point) to calculate the camera's pose relative to the ArUco marker. This calculation is offloaded to the Python Vision Processor to save ESP32 memory and CPU cycles.

It requires:
1. **Object Points**: The real-world 3D coordinates of the marker corners (e.g. `150mm x 150mm`).
2. **Image Points**: The 2D coordinates of the corners detected in the frame.
3. **Camera Matrix**: Intrinsic calibration parameters.
4. **Distortion Coefficients**: Lens correction parameters.

## Outputs to ESP32
The Python script calculates and sends the following over TCP (Command ID 701):
- `pose_x, pose_y, pose_z`: Translation in meters.
- `pose_roll, pose_pitch, pose_yaw`: Euler angles derived from the Rodrigues rotation vector.
- `marker_dist`: Euclidean distance from the camera to the marker.
- `align_score`: Pre-calculated 0-100% alignment score.
