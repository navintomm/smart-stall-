# Command Catalog

| ID | Name | Category | Payload Keys | Expects Resp | Timeout (ms) |
|---|---|---|---|---|---|
| 101 | MOVE_FORWARD | Movement | `speed` | Yes | 2000 |
| 102 | MOVE_BACKWARD | Movement | `speed` | Yes | 2000 |
| 103 | TURN_LEFT | Movement | `speed` | Yes | 2000 |
| 104 | TURN_RIGHT | Movement | `speed` | Yes | 2000 |
| 105 | STOP | Movement | none | Yes | 2000 |
| 201 | BASE_ROTATION | Arm | `angle` | Yes | 2000 |
| 202 | SHOULDER | Arm | `angle` | Yes | 2000 |
| 203 | ELBOW | Arm | `angle` | Yes | 2000 |
| 204 | WRIST | Arm | `angle` | Yes | 2000 |
| 205 | GRIPPER | Arm | `state` | Yes | 2000 |
| 301 | WATER_PUMP | Tools | `state` | Yes | 2000 |
| 302 | SOAP_PUMP | Tools | `state` | Yes | 2000 |
| 303 | BRUSH_MOTOR | Tools | `state` | Yes | 2000 |
| 304 | BRUSH_ROTATION | Tools | `speed` | Yes | 2000 |
| 401 | EMERGENCY_STOP | System | none | Yes | 2000 (retries=10) |
| 402 | RESUME | System | none | Yes | 2000 |
| 403 | RESTART | System | none | No | 2000 |
| 404 | CALIBRATION | System | none | Yes | 10000 |
| 405 | HOME_POSITION | System | none | Yes | 5000 |
| 406 | PING | System | none | Yes | 500 |

*See `lib/core/communication/protocol/catalogues/command_catalog.dart` for source definitions.*
