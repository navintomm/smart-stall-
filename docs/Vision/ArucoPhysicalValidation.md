# ArUco Physical Validation Report

This document records the physical validation of the ArUco marker tracking pipeline on the target hardware (Samsung S22).

## Pipeline Status: **SOFTWARE VERIFIED**
The following architectural elements have been verified via software tests and code review:
- The persistent `ArucoVisionWorker` background isolate handles OpenCV processing without frame drops.
- `cv.solvePnP` rigorously calculates 3D Translation and Rotation vectors (Roll, Pitch, Yaw).
- Camera Intrinsic Matrix (`CameraCalibration`) is successfully integrated into the solver.
- UI `CustomPainter` overlay correctly maps coordinates.
- Application gracefully handles OpenCV exceptions and empty frames.

---

## 1. Physical Verification (Operator Action Required)

**Device Used:** Samsung S22
**Camera:** Main Rear Camera
**Marker Dictionary:** `DICT_4X4_50`
**Configured Marker Physical Size:** ________ mm *(Check Developer Diagnostics)*
**Camera Calibration Status:** [ ] Valid  [ ] Uncalibrated / Generic

### 1.1 Detection Stability
- [ ] Marker is instantly detected.
- [ ] Bounding box accurately surrounds the physical marker on-screen.
- [ ] Moving the marker left/right/up/down tracks smoothly.
- [ ] No stuttering/lag spikes are visible while tracking.

### 1.2 Distance Validation (Metric Accuracy)
Hold the marker perfectly parallel to the camera at the known physical distances below. Wait 2 seconds for stabilization, then record the displayed distance.

| Actual Distance | Estimated Distance | Absolute Error (cm) | Error % |
|-----------------|--------------------|---------------------|---------|
| 20 cm           |                    |                     |         |
| 30 cm           |                    |                     |         |
| 40 cm           |                    |                     |         |
| 50 cm           |                    |                     |         |
| 60 cm           |                    |                     |         |

### 1.3 Pose Validation (Rotational Accuracy)
Hold the marker at approximately 40cm and slowly rotate it along individual axes.

- **Yaw** (Rotate left/right like a steering wheel):
  - [ ] Values change predictably.
  - [ ] Values are stable when rotation stops.
- **Pitch** (Tilt top edge towards/away from camera):
  - [ ] Values change predictably.
  - [ ] Distance (Z) remains relatively stable despite tilt.
- **Roll** (Tilt left edge towards/away from camera):
  - [ ] Values change predictably.

### 1.4 Failure & Edge Case Validation
- [ ] **Partially obscured marker:** Handled gracefully (loses tracking cleanly).
- [ ] **Extremely close (< 10cm):** Behavior: ________________
- [ ] **Extremely rotated (> 60 degrees):** Behavior: ________________
- [ ] **No marker visible:** UI transitions to 'Searching for Marker...'.

### 1.5 Alignment Logic
Move the marker around the frame and observe the overall `ALIGN %` score.
- [ ] Highest alignment score (>90%) occurs when the marker is dead-center.
- [ ] Score steadily drops as the marker moves to the screen edges.

---

## Conclusions
*(To be filled out by operator after testing)*

- **Known Inaccuracies:** 
- **Remaining Calibration Requirements:**
- **Ready for robotic autonomous movement?** [ ] YES  [ ] NO
