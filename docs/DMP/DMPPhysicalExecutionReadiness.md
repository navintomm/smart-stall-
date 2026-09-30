# DMP Physical Execution Readiness Audit (Checkpoint 5.1)

## 1. Existing Physical Control Architecture

The current physical control path from the Flutter app to the servos flows as follows:

1. **Flutter State (Manual/Joystick)**: UI events trigger methods like `moveServo(servoId, angle)` in `HardwareRobotRepository`.
2. **HardwareRobotRepository**: Maps string identifiers (`'base'`, `'shoulder'`, `'elbow'`) to specific protocol `cmdId` values (e.g., `BASE_ROTATION = 201`, `SHOULDER = 202`, `ELBOW = 203`) via the `CommandCatalog`.
3. **BluetoothService**: Encodes the command as a JSON string and sends it over BLE (Nordic UART Service, characteristic `6E400002...`).
4. **ESP32 Firmware (`WifiServerHandler` / `ProtocolCodec`)**: Receives the raw JSON string, decodes it into a `RobotPacket`, and passes it to the `CommandDispatcher`.
5. **ESP32 `CommandDispatcher`**: Evaluates the `cmdId` and maps it to specific hardware controllers.
6. **ESP32 `ServoController`**: Updates a `_targetAngles` array. A `tick()` function running on a 15ms timer steps the actual servo PWM signal 1 degree closer to the target every 15ms.

**CRITICAL GAP IDENTIFIED**: 
`CommandDispatcher.cpp` only contains a handler for `cmdId 201` (`BASE_ROTATION`). If Flutter sends commands for `SHOULDER` (`202`) or `ELBOW` (`203`), they fall through to the `default` case and are ignored with an `"Unknown Command ID"` warning. The ESP32 is currently deaf to shoulder/elbow commands.

## 2. Existing DMP Architecture

The newly implemented DMP preview pipeline generates data safely isolated from the physical hardware:

- **Model Structure**: `DmpResult` contains lists of `DmpTrajectorySample`.
- **Sample Structure**: Each sample contains `timeSeconds` (float), `servo1Angle` (float, degrees), and `servo2Angle` (float, degrees).
- **Scale**: A typical generated trajectory contains ~500 samples running at ~100Hz for a 5-second motion.
- **Constraints**: 
  - Only generates continuous angles; no speed or acceleration derivatives are natively bundled.
  - The trajectory encodes *velocity* implicitly through the `timeSeconds` deltas between varying angle positions.

## 3. Mapping Analysis & Gaps (DMP → Robot)

| DMP Output | Current Robot Implementation | Action Required / Gap |
| :--- | :--- | :--- |
| `servo1Angle` | `SHOULDER (202)` | Must implement `cmdId 202` in ESP32 `CommandDispatcher.cpp`. |
| `servo2Angle` | `ELBOW (203)` | Must implement `cmdId 203` in ESP32 `CommandDispatcher.cpp`. |
| `timeSeconds` | Ignored. `ServoController::tick()` overrides speed. | **MAJOR**: The ESP32 forces a 1 deg/15ms slew rate. Sending DMP angles to the current ESP32 will completely destroy the DMP's learned velocity/acceleration profile. |
| 500 Samples | `MISSION_START (601)` accepts max 10 waypoints. | **MAJOR**: ESP32 cannot receive 500 points at once. Flutter cannot send them individually via UART due to BLE latency/jitter. |

## 4. Safety Status

### Existing Mechanisms
- **Flutter**: `DmpValidator` ensures generated trajectories contain sufficient samples, preserve start/goal positions, and have no NaN/Infinite values.
- **ESP32**: `EmergencyController` triggers an emergency stop overriding all movement.
- **ESP32**: `ServoController::setAngle` safely clamps all angles between `10` and `170` degrees to prevent servo over-extension.

### Missing Mechanisms
- **Trajectory Kinematic Safety**: No collision detection or workspace boundary validation exists on the ESP32.
- **Velocity Limit Checking**: The DMP might generate angular velocities that the physical servos cannot safely track (jerk/stall risks).
- **Trajectory Connection Loss**: If BLE disconnects halfway through a 5-second streaming trajectory, the arm behavior is undefined (likely continues to the last received target).

## 5. Physical Execution Risks

1. **The Slew Rate Conflict**: The most severe risk. Because `ServoController.cpp` forces a 1 degree per 15ms speed limit, the physical robot is mathematically incapable of executing the learned DMP velocity profile using the current command infrastructure.
2. **BLE Jitter & Latency**: Sending 100 commands per second over BLE will cause queue overflow, packet dropping, and stuttering. The trajectory will look robotic and jerky, destroying the "smooth" benefit of DMP.
3. **Memory Overflow**: Sending the entire 500-sample JSON array to the ESP32 at once will crash the `WifiServerHandler`, which has a 2048-byte line buffer limit.

## 6. Required Execution Architecture

To safely and accurately execute DMP trajectories on the physical SCARA, we must design a **Batched Trajectory Streaming Architecture**:

1. **New BLE Protocol Command**: `TRAJECTORY_CHUNK (cmdId 610)`
   - Accepts arrays of `[time_ms, s1_angle, s2_angle]`.
   - Chunks must fit within the 2048-byte UART buffer (e.g., 20 samples per chunk).
2. **Flutter `TrajectoryScheduler`**:
   - Resides in the `HardwareRobotRepository`.
   - Breaks `DmpResult` into chunks.
   - Streams chunks slightly ahead of the execution time to maintain a buffer on the ESP32.
3. **ESP32 `TrajectoryBuffer` (Ring Buffer)**:
   - Receives chunks and stores them in a fixed-size ring buffer (e.g., capacity 50 samples).
4. **ESP32 `TrajectoryExecutor`**:
   - Bypasses the standard `ServoController::tick()` slew rate.
   - Uses a high-frequency hardware timer to interpolate exact servo angles based on the current execution `time_ms`.

## 7. Next Steps & Recommendations

**DO NOT ATTEMPT TO EXECUTE DMP USING THE EXISTING COMMANDS.**

The next checkpoint must focus purely on updating the ESP32 Firmware and the Flutter Protocol layer to support the required execution architecture.

**Recommended Phased Implementation**:
1. Implement missing `SHOULDER` and `ELBOW` command dispatching in ESP32 for manual control testing.
2. Implement the `TRAJECTORY_CHUNK` protocol and Ring Buffer in ESP32.
3. Implement the `TrajectoryScheduler` in Flutter.
4. Perform a dry-run test (send DMP to ESP32 without servos powered) to validate timing logs.
5. Finally, execute the physical arm.
