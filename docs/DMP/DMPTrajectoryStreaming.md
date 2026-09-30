# DMP Trajectory Streaming Infrastructure

## 1. Problem Being Solved
The DMP pipeline generates fluid, time-dependent SCARA trajectories. Sending these as discrete, real-time positional commands over BLE UART introduces latency, jitter, and destroys the learned temporal profile. Furthermore, the existing firmware forces a fixed `1 degree / 15 ms` slew rate (`ServoController::tick`), which overrides any velocity profile the DMP generated.

## 2. Why Direct Per-Sample Commands Are Inappropriate
- **BLE Limitations**: UART streaming cannot guarantee consistent microsecond-level timing. Dropped packets or network delays will cause stuttering and physically dangerous "catch-up" arm movements.
- **Slew Rate Conflict**: The existing hardware abstraction intentionally filters all input to 15ms steps. Attempting to bypass this on a per-packet basis over BLE is architecturally flawed.
- **Payload Limits**: A full trajectory is ~500 samples. Sending all at once overflows the ESP32's 2048-byte network receive buffer.

## 3. Protocol Architecture
We introduce a **Batched Trajectory Streaming Architecture**:
1. `TRAJECTORY_CONTROL` (cmdId 611): Manages the lifecycle (BEGIN, END, ABORT).
2. `TRAJECTORY_CHUNK` (cmdId 610): Transmits bite-sized chunks of the trajectory (up to 20 samples per chunk).
3. **ESP32 Ring Buffer**: Buffers incoming chunks securely with a fixed memory footprint (`MAX_BUFFER_SIZE = 50`).
4. **Trajectory Executor**: An isolated firmware component that bypasses `ServoController::tick`'s slew rate and uses an internal clock to interpolate incoming coordinates on the fly.

## 4. Packet Structure
The existing JSON-based protocol (via `ProtocolCodec`) is reused to maintain compatibility.
A chunk packet looks like:
```json
{
  "ver": "2.0",
  "type": "command",
  "cmdId": 610,
  "seq": 45,
  "ts": 1700000000,
  "data": {
    "samples": [
      [0, 90.0, 90.0],
      [10, 90.1, 90.2]
    ]
  },
  "crc": 123
}
```

## 5. Timestamp Encoding
Timestamps are encoded as `uint32_t` integer milliseconds (calculated as `timeSeconds * 1000`). This avoids float precision issues and allows direct comparison with the ESP32's `millis()` timer.
Angles are encoded as 1-decimal-place floats (e.g., `90.1`) to save JSON string space.

## 6. Chunking
- Max samples per chunk: **20**
- 20 samples * ~22 bytes per sample JSON string = ~440 bytes. This easily fits within the 2048-byte limit of `WifiServerHandler`.
- Flutter deterministically splits `List<DmpTrajectorySample>` into these 20-sample chunks.

## 7. Ring Buffer
The `TrajectoryExecutor` uses a circular buffer (`_buffer[50]`, `_head`, `_tail`, `_count`).
It prevents dynamic memory fragmentation and rejects samples if overflowing or non-monotonic timestamps are detected.

## 8. Trajectory Executor
The `TrajectoryExecutor` operates via a `tick()` function called in the main loop. It maintains its own start time (`_startTimeMs`) initialized only when a `TRAJECTORY_CONTROL: END` packet verifies sufficient buffer capacity.

## 9. Timestamp Interpolation
The executor calculates elapsed time: `elapsed = millis() - _startTimeMs`.
It finds the surrounding buffer samples `s0` and `s1`. If the current time falls between them, it performs linear interpolation to determine the exact instantaneous desired angle:
`alpha = (elapsed - s0.timeMs) / (s1.timeMs - s0.timeMs)`
`desAngle = s0.angle + alpha * (s1.angle - s0.angle)`

## 10. Safety Flow
Before the interpolated angles are sent to the servo hardware, they are subjected to:
1. `EmergencyController::isEmergency()` check -> aborts trajectory immediately.
2. Underflow check -> if network lag causes the buffer to run empty, the trajectory is safely aborted.
3. Alpha clamping -> prevents extreme calculations if timestamps overlap.

## 11. Connection-Loss Handling
If communication is lost or a buffer underflow occurs (no upcoming samples to process in time), the `TrajectoryExecutor` will abort and return the robot to `IDLE` state. It does NOT continue moving blindly to the last known position.

## 12. Dry-Run Architecture
**CRITICAL: Physical Servo Execution is DISABLED in this checkpoint.**
The `_isDryRun` flag is hardcoded to `true`. The executor performs all parsing, buffering, and interpolation mathematically, but instead of calling `ServoController::setAngle`, it outputs telemetry to the serial log:
`DRY-RUN t=150 ms | a1=91.20 | a2=110.50`

## 13. Flutter ↔ ESP32 Data Flow
`DmpResult` → `TrajectoryChunker` → `HardwareRobotRepository (future)` → `Bluetooth UART` → `ProtocolCodec (ESP32)` → `CommandDispatcher (ESP32)` → `TrajectoryExecutor (ESP32)` → `Serial Telemetry`.

## 14. Current Limitations
- BLE transmission logic (the scheduling of sending chunks over time) is not fully implemented in Flutter yet (only the chunking algorithm is present).

## 15. Future Physical Execution Requirements
When transitioning to physical execution in the next checkpoint:
- `_isDryRun` must be toggled via a secure command.
- The interpolated angles must still be passed through the `10`-`170` clamp in `ServoController`.
- The physical workspace constraints must be respected.
