# SmartStall Communication Protocol (V1)

## Overview
This document specifies the exact JSON protocol used between the SmartStall Operator App (Flutter) and the Robotic System (ESP32/C++). 

## Message Framing
All messages are sent as raw UTF-8 JSON strings terminated by a newline character \n.

## 1. Commands (App -> Robot)

A command packet must contain the following fields:
- commandId (int): Unique incremental ID.
- commandType (string): The action to perform.
- payload (object): Arguments for the command.
- 	imestamp (int): Unix epoch in milliseconds.
- protocolVersion (string): Fixed to "1.0".

### Command Catalogue

| Command Type | Payload Arguments | Description |
|---|---|---|
| MOVE_ROBOT | direction (String), speed (int) | Drives the base. |
| STOP_ROBOT | None | Halts base movement immediately. |
| EMERGENCY_STOP| None | Halts ALL actuators and locks the robot. |
| MOVE_SERVO | id (String), ngle (int) | Moves a specific arm joint. |
| TOGGLE_TOOL| id (String), state (bool)| Turns pump/brush on or off. |
| SET_MODE | mode (String) | Changes cleaning mode (e.g. AUTO, MANUAL). |
| CALIBRATE | None | Runs zeroing sequence on all servos. |
| PING | None | Requests an immediate diagnostic packet response. |

### Example Command
`json
{
  "commandId": 1042,
  "commandType": "MOVE_SERVO",
  "payload": {
    "id": "joint_1",
    "angle": 90
  },
  "timestamp": 1698765432000,
  "protocolVersion": "1.0"
}
`

## 2. Responses (Robot -> App)

A response packet explicitly acknowledges a command by referencing its commandId.

### Example Response (Success)
`json
{
  "commandId": 1042,
  "isSuccess": true,
  "errorCode": 0,
  "message": "Servo moved",
  "data": {}
}
`

### Example Response (Error)
`json
{
  "commandId": 1042,
  "isSuccess": false,
  "errorCode": 403,
  "message": "Emergency Stop is active. Command rejected."
}
`

## 3. Telemetry Packets (Robot -> App)
Telemetry is streamed periodically (e.g., every 1000ms).

### Example Telemetry
`json
{
  "telemetry": {
    "battery": 87,
    "water": 45,
    "soap": 90,
    "brush": 12,
    "temp": 42,
    "rssi": -65,
    "fw": "v1.0.4",
    "mode": "MANUAL",
    "estop": false,
    "uptime": 3600
  },
  "timestamp": 1698765433000
}
`

## 4. Diagnostics Packets (Robot -> App)
Diagnostics are returned when responding to a PING command or when network conditions shift drastically.

### Example Diagnostics
`json
{
  "diagnostics": {
    "pingMs": 14,
    "packetLoss": 0.0,
    "signalDbm": -65
  }
}
`

## 5. Security & Checksums
In V1, no encryption is enforced. A trailing 8-bit checksum is calculated by summing the byte values of the JSON string modulo 256. (Currently loosely validated).
