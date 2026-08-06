#ifndef LOCALIZATION_ENGINE_H
#define LOCALIZATION_ENGINE_H

#include <Arduino.h>
#include "MarkerRegistry.h"

enum LocalizationState {
    LOC_SEARCHING,
    LOC_MARKER_DETECTED,
    LOC_ALIGNMENT_REQUIRED,
    LOC_READY,
    LOC_LOST,
    LOC_ERROR
};

class LocalizationEngine {
public:
    static void init();
    static void tick();
    
    static LocalizationState getState();
    static String getStateName();
    
    static int getMarkerId();
    static float getConfidence();
    static unsigned long getLastDetectionTime();

private:
    static LocalizationState _currentState;
    static int _currentMarkerId;
    static float _confidence;
    static unsigned long _lastDetectionTime;
    
    static void evaluateState();
};

#endif
