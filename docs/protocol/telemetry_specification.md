# Telemetry Specification

Periodic broadcast (default 1000ms).

### Schema
- `bat`: Battery % (Double)
- `water`: Tank % (Double)
- `soap`: Tank % (Double)
- `brush`: Wear % (Double)
- `temp`: Motor Temp C (Double)
- `volt`: System Voltage (Double)
- `amp`: Current Draw (Double)
- `rssi`: Signal dBm (Int)
- `cpu`: Core usage % (Double)
- `mem`: Heap usage % (Double)
- `mode`: Robot State (String)
- `estop`: Emergency locked (Bool)
- `fw`: Firmware Version (String)
- `uptime`: Uptime in ms (Int)
- `err`: Last Error Code (Int)
- `lqi`: Link Quality Indicator (Int)
