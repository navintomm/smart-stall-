#ifndef SYSTEM_HEALTH_MANAGER_H
#define SYSTEM_HEALTH_MANAGER_H

#include <Arduino.h>

class SystemHealthManager {
private:
    static unsigned long lastLoopTime;
    static unsigned long maxLoopTime;
    static unsigned long currentLoopTime;
    
    static unsigned long lastSecondTime;
    static int loopCount;
    static int currentFps;

    static unsigned long lastWatchdogTick;
    static bool watchdogTriggered;

public:
    static void init();
    static void tickStart();
    static void tickEnd();
    static void petWatchdog();
    
    static unsigned long getMaxLoopTimeMs() { return maxLoopTime; }
    static unsigned long getCurrentLoopTimeMs() { return currentLoopTime; }
    static int getLoopFps() { return currentFps; }
    static uint32_t getFreeHeap();
    
    static bool isWatchdogTriggered() { return watchdogTriggered; }
};

#endif
