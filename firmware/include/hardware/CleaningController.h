#ifndef CLEANING_CONTROLLER_H
#define CLEANING_CONTROLLER_H

#include <Arduino.h>
#include <ArduinoJson.h>

enum CleaningState {
    STATE_IDLE,
    STATE_PREPARING,
    STATE_WETTING,
    STATE_BRUSHING,
    STATE_SCRUBBING,
    STATE_RINSING,
    STATE_COMPLETED,
    STATE_PAUSED,
    STATE_EMERGENCY,
    STATE_ERROR
};

class CleaningController {
public:
    static void init();
    static void tick();

    static void start();
    static void pause();
    static void resume();
    static void stop();

    static CleaningState getState();
    static String getStateName();
    static String getStepName();
    static int getProgress();
    static int getTimeRemaining();
    static int getElapsedTime();
    static int getCycleCount();
    static String getAbortReason();

private:
    static CleaningState currentState;
    static CleaningState previousState;
    static unsigned long stateStartTime;
    static unsigned long cleaningStartTime;
    static int cleaningCycleCount;
    static String abortReason;
    static int progress;
    static int timeRemaining;
    static int elapsedTime;
    static String currentStep;
    
    static void setState(CleaningState newState, const String& stepName);
    static void executeSafetyChecks();
    
    static void executePreparing(unsigned long elapsed);
    static void executeWetting(unsigned long elapsed);
    static void executeBrushing(unsigned long elapsed);
    static void executeScrubbing(unsigned long elapsed);
    static void executeRinsing(unsigned long elapsed);
    static void executeCompleted(unsigned long elapsed);
};

#endif
