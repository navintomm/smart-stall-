# SMARTSTALL DMP Implementation Audit

## 1. Current DMP Architecture (Python)
The current DMP implementation resides in `scara_dmp/` and is fully functional as an isolated Python pipeline.
* **Input/Output**: Accepts CSV files with `timestamp_ms` and joint columns (`servo1_angle`, `servo2_angle`). Outputs a generated CSV trajectory and visualization plots.
* **Servo Architecture**: Implements a `MultiDMP` class that maps a `DMP1D` instance to each joint (Servo 1 and Servo 2).
* **Canonical System**: Standard exponential decay `s_dot = -alpha_s * s / tau`.
* **Transformation System**: Spring-damper system `dz = alpha_z * (beta_z * (g - y) - z) + f`.
* **Basis Functions & Weights**: Gaussian basis functions exponentially spaced in phase space. Forcing-function weights are learned via Locally Weighted Regression (LWR).
* **Derivatives & Preprocessing**: Uses a Savitzky-Golay filter (`scipy.signal.savgol_filter`) for smoothing and calculating velocity/acceleration. It deliberately forces a steady state at the first and last 10 samples to prevent weight explosion.
* **Evaluation Metrics**: Implemented metrics include MAE, RMSE, Maximum Error, Smoothness (sum of squared jerk), start position preservation, goal position preservation, and NaN/Inf checks.
* **Current Status**: Operates perfectly on synthetic/demo data (`test_pipeline.py`) but operates entirely offline.

## 2. Current Flutter Teaching Architecture
* **User Flow**: The user accesses the `ManualTeachingPage` and presses "Start Teaching". The `ManualTeachingNotifier` sends a 'T' command via BLE to the ESP32.
* **Recording**: Flutter listens to incoming BLE strings, parsing integers into `MotionSample` objects containing `timestampMs` and `servo1Angle`.
* **Saving**: When stopped, samples form a `MotionRecording`, which is converted to a `Routine` and saved to the local `MotionLibraryProvider`.
* **Sampling/Filtering**: Sampling frequency is dictated directly by the ESP32 transmission rate. There is currently no deduplication or filtering of stationary samples on the Flutter side.

## 3. Current Routine/ArUco Architecture
* **Marker Association**: The `Routine` model has an optional `markerId` integer field.
* **Filtering**: In the `RoutineSelectorCard`, routines are filtered to show only those matching the currently detected camera `markerId`, alongside global routines (`markerId == null`).
* **Transmission**: ArUco markers and Routine data are currently **not** transmitted to the ESP32.

## 4. Current Bluetooth Architecture
* **Capabilities**: The `AppBluetoothService` successfully connects to the Nordic UART Service, listens to the TX characteristic, and sends strings via the RX characteristic without response.
* **Current Usage**: Used only for simple control characters ('T' for teach, 'S' for stop) and receiving raw joint angles.

## 5. Current End-to-End Data Flow
```text
USER
  ↓
Manual Teaching UI
  ↓
Motion Recording (Flutter memory)
  ↓
Save
  ↓
Routine (Local Motion Library)
  ↓
[CURRENT STOP POINT]
```
*Note: The Python DMP pipeline is isolated and currently accepts CSV files; there is no bridge connecting the Flutter `Routine` to the Python DMP.*

## 6. Existing DMP Capabilities
* Multi-DOF trajectory imitation and generation.
* Robust data preprocessing and Savitzky-Golay filtering.
* Comprehensive evaluation metrics and trajectory plotting.
* Simulated CSV dataset generation.

## 7. Missing Capabilities
* No Flutter-to-Python execution bridge.
* No stationary/duplicate sample filtering in Flutter.
* No mechanism to transmit generated trajectories (or DMP weights) back to the ESP32.
* No CSV export feature directly from Flutter's `ManualTeachingProvider`.

## 8. Motion Preview Status
**Motion Preview is NOT currently implemented.** 
While there is a `_PreviewSheet` in the `motion_library_page.dart`, it only serves as a textual overview. There is no Canvas/Painter rendering, 2D/3D SCARA visualization, or trajectory graphing in the Flutter app.

## 9. Validation Status
* **SOFTWARE VALIDATED**: Python DMP pipeline (math, generation, plotting) and Flutter Manual Teaching data capture logic.
* **PHYSICAL HARDWARE VALIDATED**: ArUco vision tracking (documented in `ArucoPhysicalValidation.md`) and BLE UART string receiving.
* **NOT YET VALIDATED**: Physical robot execution of DMP-generated trajectories.

## 10. Safety Status
**DMP output is currently completely isolated from physical robot execution.**
There is no code path that allows a DMP-generated trajectory to be transmitted to the ESP32 or servos. The Bluetooth service only sends single-character flags.

## 11. Recommended Next Implementation Stage
**DMP Motion Preview + Trajectory Validation**
Before bridging the physical hardware, the next step should be visualizing the recorded and DMP-generated trajectories directly within the Flutter app to ensure they are safe and correct.
