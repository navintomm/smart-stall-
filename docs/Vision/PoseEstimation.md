# Pose Estimation

## solvePnP
Pose estimation uses `cv::solvePnP` (Perspective-n-Point) to calculate the camera's pose relative to the ArUco marker.

It requires:
1. **Object Points**: The real-world 3D coordinates of the marker corners (e.g. `150mm x 150mm`).
2. **Image Points**: The 2D coordinates of the corners detected in the frame.
3. **Camera Matrix**: Intrinsic calibration parameters.
4. **Distortion Coefficients**: Lens correction parameters.

## Outputs
- **tvec (Translation Vector)**: The real-world `(X, Y, Z)` translation in meters from the camera to the marker.
- **rvec (Rotation Vector)**: The rotation in Rodrigues representation. We convert this into a standard rotation matrix using `cv::Rodrigues()`, and then extract Euler Angles (Roll, Pitch, Yaw).
