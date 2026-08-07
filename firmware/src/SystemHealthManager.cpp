#include "SystemHealthManager.h"
#include "Logger.h"

unsigned long SystemHealthManager::lastLoopTime = 0;
unsigned long SystemHealthManager::maxLoopTime = 0;
unsigned long SystemHealthManager::currentLoopTime = 0;
unsigned long SystemHealthManager::lastSecondTime = 0;
int SystemHealthManager::loopCount = 0;
int SystemHealthManager::currentFps = 0;
unsigned long SystemHealthManager::lastWatchdogTick = 0;
bool SystemHealthManager::watchdogTriggered = false;

void SystemHealthManager::init() {
    lastLoopTime = millis();
    lastSecondTime = millis();
    lastWatchdogTick = millis();
    watchdogTriggered = false;
    Logger::info("SysHealth", "System Health Manager Initialized.");
}

void SystemHealthManager::tickStart() {
    lastLoopTime = millis();
}

void SystemHealthManager::tickEnd() {
    unsigned long now = millis();
    currentLoopTime = now - lastLoopTime;
    
    if (currentLoopTime > maxLoopTime) {
        maxLoopTime = currentLoopTime;
        if (maxLoopTime > 100) { // Warning if loop takes > 100ms
            Logger::warning("SysHealth", "Long loop detected: " + String(maxLoopTime) + "ms");
        }
    }
    
    loopCount++;
    if (now - lastSecondTime >= 1000) {
        currentFps = loopCount;
        loopCount = 0;
        lastSecondTime = now;
        
        // Check Watchdog
        if (now - lastWatchdogTick > 5000) {
            if (!watchdogTriggered) {
                Logger::critical("SysHealth", "WATCHDOG TRIGGERED! Main loop stalled for >5s.");
                watchdogTriggered = true;
            }
        }
    }
}

void SystemHealthManager::petWatchdog() {
    lastWatchdogTick = millis();
    watchdogTriggered = false;
}

uint32_t SystemHealthManager::getFreeHeap() {
#ifdef ESP32
    return ESP.getFreeHeap();
#else
    return 8192; // Dummy for mock environments
#endif
}
