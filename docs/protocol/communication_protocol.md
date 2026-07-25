# Communication Protocol Architecture (V2)

## Overview
This defines the robust V2 packet protocol. It is transport agnostic and designed for stability across Wi-Fi, BLE, and Serial connections.

## Packet Types
- `handshake`: Initial connection setup.
- `heartbeat`: Maintains connection alive.
- `command`: App -> Robot instruction.
- `response`: Robot -> App acknowledgement.
- `telemetry`: Periodic sensor payload.
- `diagnostics`: Intensive health metrics.
- `systemEvent`: Asynchronous triggers (e.g. boot complete).
- `error`: Alert when faults occur.
