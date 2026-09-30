#ifndef TRAJECTORY_EXECUTOR_H
#define TRAJECTORY_EXECUTOR_H

#include <Arduino.h>
#include <ArduinoJson.h>

struct TrajectorySample {
    uint32_t timeMs;
    float servo1Angle;
    float servo2Angle;
};

class TrajectoryExecutor {
public:
    static void init();
    static void tick();
    
    // Command Interface
    static void handleChunk(const JsonDocument& payload);
    static void handleControl(const String& action); // "BEGIN", "END", "ABORT"
    
private:
    static const int MAX_BUFFER_SIZE = 50;
    static TrajectorySample _buffer[MAX_BUFFER_SIZE];
    static int _head;
    static int _tail;
    static int _count;
    
    static bool _isActive;
    static bool _isDryRun; // Safety Gate - Defaults to TRUE
    static uint32_t _startTimeMs;
    
    // Safety & State
    static void pushSample(uint32_t t, float a1, float a2);
    static bool peekNextSample(TrajectorySample& outSample);
    static void consumeSample();
    static void clearBuffer();
    static void abort();
};

#endif
