#ifndef RECOVERY_MANAGER_H
#define RECOVERY_MANAGER_H

#include <Arduino.h>

class RecoveryManager {
private:
    static unsigned long lastWifiCheck;
    static unsigned long lastLocCheck;
    static bool wifiWasConnected;

public:
    static void init();
    static void tick();
};

#endif
