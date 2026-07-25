# Error Codes

| Code | Name | Severity | Recovery | Description |
|---|---|---|---|---|
| 1001 | UNKNOWN_COMMAND | Warning | Verify Protocol | Command ID not recognized |
| 1002 | INVALID_PAYLOAD | Warning | Check command parameters | Missing or malformed arguments |
| 1003 | TIMEOUT | Warning | Retry command | Operation took too long |
| 1004 | CRC_FAILURE | Warning | Packet dropped, will retry automatically | Checksum mismatch |
| 2001 | MOTOR_FAULT | Critical | Clear obstruction and recalibrate | Overcurrent or stall detected on motor |
| 2002 | LOW_BATTERY | Warning | Return to dock | Battery below safe threshold |
| 2003 | EMERGENCY_ACTIVE | Info | Release E-Stop to resume operations | Robot is currently locked by E-Stop |
| 2004 | PUMP_FAILURE | Critical | Check fluid lines | Pump motor blocked or dry |
| 2005 | BRUSH_FAILURE | Critical | Clean brush assembly | Brush motor jammed |
| 3001 | COMMUNICATION_LOST | Fatal | Re-establish connection | Heartbeat timeout |
