#include "RecoveryManager.h"
#include "SystemHealthManager.h"
#include "Logger.h"
#include "hardware/EmergencyController.h"
#include "vision/LocalizationEngine.h"
#include "navigation/MissionPlanner.h"
#include <WiFi.h>

unsigned long RecoveryManager::lastWifiCheck = 0;
unsigned long RecoveryManager::lastLocCheck = 0;
bool RecoveryManager::wifiWasConnected = false;

void RecoveryManager::init() {
    lastWifiCheck = millis();
    lastLocCheck = millis();
    
#ifdef ESP32
    wifiWasConnected = (WiFi.status() == WL_CONNECTED);
#else
    wifiWasConnected = true;
#endif

    Logger::info("Recovery", "Recovery Manager Initialized.");
}

void RecoveryManager::tick() {
    unsigned long now = millis();
    
    // Check Wi-Fi Connection Health
    if (now - lastWifiCheck > 5000) {
        lastWifiCheck = now;
#ifdef ESP32
        bool isConnected = (WiFi.status() == WL_CONNECTED);
        if (!isConnected && wifiWasConnected) {
            Logger::error("Recovery", "Wi-Fi Connection Lost! Attempting reconnect in background...");
            // Wi-Fi auto-reconnects natively if set up, but we flag the state
        } else if (isConnected && !wifiWasConnected) {
            Logger::info("Recovery", "Wi-Fi Connection Restored!");
        }
        wifiWasConnected = isConnected;
#endif
    }
    
    // Check System Watchdog
    if (SystemHealthManager::isWatchdogTriggered()) {
        if (!EmergencyController::isEmergency()) {
            Logger::critical("Recovery", "Triggering Emergency Stop due to Watchdog timeout!");
            EmergencyController::triggerEmergencyStop();
        }
    }
    
    // Check Localization Health during Missions
    if (now - lastLocCheck > 2000) {
        lastLocCheck = now;
        if (MissionPlanner::getState() == MISSION_NAVIGATING || MissionPlanner::getState() == MISSION_ALIGNING) {
            if (LocalizationEngine::getState() == LOC_ERROR) {
                Logger::error("Recovery", "Localization Fatal Error during Mission! Pausing Mission.");
                MissionPlanner::pauseMission();
            }
        }
    }
}
