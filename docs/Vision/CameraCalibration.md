# Camera Calibration

## Overview
Camera calibration is the prerequisite for accurate pose estimation. Before `solvePnP` can run, the ESP32 vision system must know the camera's intrinsic parameters.

## Intrinsic Camera Matrix (K)
The intrinsic matrix represents the focal length and optical center of the camera:
```
[ fx   0  cx ]
[  0  fy  cy ]
[  0   0   1 ]
```
- `fx`, `fy`: Focal length in pixels.
- `cx`, `cy`: Principal point (usually image center).

## Distortion Coefficients
Lenses introduce radial and tangential distortion. We use a 5-parameter distortion vector `[k1, k2, p1, p2, k3]` to correct this before estimation.

## Implementation Details
The `CalibrationManager` loads these matrices upon boot. For the presentation build, these values are mocked as an ideal pinhole camera with zero distortion to ensure stable tracking.
