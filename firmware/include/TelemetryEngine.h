#ifndef TELEMETRY_ENGINE_H
#define TELEMETRY_ENGINE_H

#include <Arduino.h>

class TelemetryEngine {
public:
    static void init();
    static void tick(void (*sendCallback)(const String&));

private:
    static unsigned long _lastTelemetryTime;
};

#endif // TELEMETRY_ENGINE_H
