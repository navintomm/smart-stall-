# Firmware Health & Recovery System

## 1. System Health Manager
The `SystemHealthManager` acts as the primary diagnostic tool for the ESP32.
- **Loop Time Tracking**: Measures the exact duration of each `loop()` execution in milliseconds. A warning is logged if the loop exceeds 100ms.
- **FPS Tracking**: Calculates the frequency of loops per second.
- **Heap Monitoring**: Monitors the Free Heap via `ESP.getFreeHeap()` to detect memory leaks.
- **Software Watchdog**: If `SystemHealthManager::tickEnd()` is not reached within 5000ms, the watchdog triggers, signaling a critical stall in the firmware loop.

## 2. Recovery Manager
The `RecoveryManager` handles autonomous fault recovery:
- **Wi-Fi Connectivity**: Detects drops in TCP sockets or Wi-Fi radio and attempts background reconnection.
- **Watchdog Intervention**: Triggers `EmergencyController::triggerEmergencyStop()` if the Software Watchdog fires, physically cutting power to the motors to prevent runaway.
- **Localization Loss**: Pauses the `MissionPlanner` if the `LocalizationEngine` enters a FATAL error state during active navigation, preventing blind movement.

## 3. Telemetry Integration
Health metrics are broadcast at 1Hz via the `RobotPacket` payload under the fields `sys_loop_ms`, `sys_fps`, `sys_heap`, and `sys_wdg`. These metrics are visualized in real-time within the Flutter Developer Center.
