#ifndef CONFIG_H
#define CONFIG_H

namespace Config {
    // Wi-Fi Configuration
    const char* const WIFI_SSID = "SMART_STALL_NETWORK";
    const char* const WIFI_PASS = "admin1234";

    // Server Configuration
    const int TCP_PORT = 8888;
    const int CLIENT_TIMEOUT_MS = 5000;

    // Telemetry Configuration
    const int TELEMETRY_INTERVAL_MS = 1000;

    // Firmware Information
    const char* const FIRMWARE_VERSION = "v1.0.0";
    const char* const PROTOCOL_VERSION = "2.0";

    // Pins (Placeholders for future phases)
    const int PIN_PUMP_WATER = 12;
    const int PIN_PUMP_SOAP = 13;
    const int PIN_MOTOR_BRUSH = 14;
    const int PIN_SERVO_BASE = 15;
}

#endif // CONFIG_H
