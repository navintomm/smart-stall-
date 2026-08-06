#include "hardware/CleaningController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/MotorController.h"
#include "hardware/SensorManager.h"
#include "hardware/EmergencyController.h"
#include "vision/LocalizationEngine.h"
#include "vision/AlignmentEngine.h"
#include "Logger.h"

CleaningState CleaningController::currentState = STATE_IDLE;
CleaningState CleaningController::previousState = STATE_IDLE;
unsigned long CleaningController::stateStartTime = 0;
unsigned long CleaningController::cleaningStartTime = 0;
int CleaningController::cleaningCycleCount = 0;
String CleaningController::abortReason = "";
int CleaningController::progress = 0;
int CleaningController::timeRemaining = 0;
int CleaningController::elapsedTime = 0;
String CleaningController::currentStep = "Idle";

// Estimated total duration in ms
const int TOTAL_DURATION_MS = 2000 + 4000 + 6000 + 5000 + 4000;

void CleaningController::init() {
    currentState = STATE_IDLE;
    progress = 0;
    timeRemaining = 0;
    elapsedTime = 0;
    currentStep = "Idle";
    abortReason = "";
}

void CleaningController::start() {
    if (currentState == STATE_IDLE || currentState == STATE_COMPLETED || currentState == STATE_ERROR) {
        if (LocalizationEngine::getState() != LOC_READY || !AlignmentEngine::isAligned()) {
            Logger::error("CleaningEngine", "Cannot start. Localization not ready or not aligned.");
            abortReason = "Alignment Required";
            setState(STATE_ERROR, "Error: Not Aligned");
            return;
        }

        cleaningStartTime = millis();
        abortReason = "";
        setState(STATE_PREPARING, "Initializing");
    }
}

void CleaningController::pause() {
    if (currentState != STATE_IDLE && currentState != STATE_COMPLETED && currentState != STATE_ERROR && currentState != STATE_PAUSED && currentState != STATE_EMERGENCY) {
        previousState = currentState;
        setState(STATE_PAUSED, "Paused");
        
        // Stop actuators immediately
        PumpController::stop(0);
        PumpController::stop(1);
        BrushController::stop();
        MotorController::stop();
    }
}

void CleaningController::resume() {
    if (currentState == STATE_PAUSED) {
        setState(previousState, currentStep); // restore step name if possible, or just default
    }
}

void CleaningController::stop() {
    setState(STATE_IDLE, "Stopped");
    abortReason = "Manual Stop";
    
    // Stop all actuators
    PumpController::stop(0);
    PumpController::stop(1);
    BrushController::stop();
    MotorController::stop();
}

void CleaningController::setState(CleaningState newState, const String& stepName) {
    currentState = newState;
    currentStep = stepName;
    stateStartTime = millis();
    Logger::info("CleaningEngine", "Transition to " + getStateName() + " (" + stepName + ")");
}

void CleaningController::executeSafetyChecks() {
    if (currentState == STATE_IDLE || currentState == STATE_COMPLETED || currentState == STATE_PAUSED || currentState == STATE_ERROR) {
        return;
    }

    if (EmergencyController::isEmergency()) {
        Logger::warning("CleaningEngine", "Emergency Stop Triggered!");
        abortReason = "Emergency Stop";
        setState(STATE_EMERGENCY, "Emergency Stop");
        PumpController::stop(0);
        PumpController::stop(1);
        BrushController::stop();
        MotorController::stop();
        return;
    }

    if (SensorManager::getMotorTemp() >= 65.0) { // Critical Temp
        Logger::error("CleaningEngine", "Critical Motor Temp! Aborting.");
        abortReason = "Critical Temperature";
        setState(STATE_ERROR, "Error: Overheating");
        PumpController::stop(0);
        PumpController::stop(1);
        BrushController::stop();
        MotorController::stop();
        return;
    }

    if (SensorManager::getWaterLevel() <= 5) {
        Logger::warning("CleaningEngine", "Low Water! Pausing cleaning.");
        abortReason = "Water Empty";
        pause();
        return;
    }

    if (SensorManager::getSoapLevel() <= 5) {
        Logger::warning("CleaningEngine", "Low Soap! Pausing cleaning.");
        abortReason = "Soap Empty";
        pause();
        return;
    }
}

void CleaningController::executePreparing(unsigned long elapsed) {
    if (elapsed > 2000) {
        setState(STATE_WETTING, "Spraying Water");
    }
}

void CleaningController::executeWetting(unsigned long elapsed) {
    PumpController::start(0); // Water
    
    if (LocalizationEngine::getState() != LOC_LOST) {
        MotorController::moveForward(50);
    } else {
        MotorController::stop();
    }
    
    if (elapsed > 4000) {
        PumpController::stop(0);
        MotorController::stop();
        setState(STATE_BRUSHING, "Applying Soap & Brushing");
    }
}

void CleaningController::executeBrushing(unsigned long elapsed) {
    PumpController::start(1); // Soap
    BrushController::start();
    
    if (LocalizationEngine::getState() != LOC_LOST) {
        MotorController::turnLeft(50);
        if (elapsed > 2000 && elapsed < 4000) {
            MotorController::turnRight(50);
        }
    } else {
        MotorController::stop();
    }
    
    if (elapsed > 6000) {
        PumpController::stop(1);
        MotorController::stop();
        setState(STATE_SCRUBBING, "Deep Scrubbing");
    }
}

void CleaningController::executeScrubbing(unsigned long elapsed) {
    BrushController::start();
    
    if (LocalizationEngine::getState() != LOC_LOST) {
        MotorController::moveForward(40);
    } else {
        MotorController::stop();
    }
    
    if (elapsed > 5000) {
        BrushController::stop();
        MotorController::stop();
        setState(STATE_RINSING, "Final Rinse");
    }
}

void CleaningController::executeRinsing(unsigned long elapsed) {
    PumpController::start(0); // Water
    
    if (LocalizationEngine::getState() != LOC_LOST) {
        MotorController::moveBackward(50);
    } else {
        MotorController::stop();
    }
    
    if (elapsed > 4000) {
        PumpController::stop(0);
        MotorController::stop();
        setState(STATE_COMPLETED, "Done");
        cleaningCycleCount++;
    }
}

void CleaningController::executeCompleted(unsigned long elapsed) {
    if (elapsed > 5000) {
        setState(STATE_IDLE, "Idle");
    }
}

void CleaningController::tick() {
    executeSafetyChecks();

    unsigned long elapsed = millis() - stateStartTime;
    
    // Calculate global elapsed time if running
    if (currentState != STATE_IDLE && currentState != STATE_COMPLETED && currentState != STATE_ERROR && currentState != STATE_EMERGENCY) {
        elapsedTime = (millis() - cleaningStartTime) / 1000;
        int totalSeconds = TOTAL_DURATION_MS / 1000;
        timeRemaining = totalSeconds - elapsedTime;
        if (timeRemaining < 0) timeRemaining = 0;
        
        progress = (elapsedTime * 100) / totalSeconds;
        if (progress > 100) progress = 100;
    }

    switch (currentState) {
        case STATE_IDLE:
            progress = 0;
            timeRemaining = 0;
            break;
            
        case STATE_PREPARING:
            executePreparing(elapsed);
            break;

        case STATE_WETTING:
            executeWetting(elapsed);
            break;

        case STATE_BRUSHING:
            executeBrushing(elapsed);
            break;

        case STATE_SCRUBBING:
            executeScrubbing(elapsed);
            break;

        case STATE_RINSING:
            executeRinsing(elapsed);
            break;

        case STATE_COMPLETED:
            progress = 100;
            timeRemaining = 0;
            executeCompleted(elapsed);
            break;

        case STATE_PAUSED:
            // Waiting for resume()
            break;

        case STATE_EMERGENCY:
            if (!EmergencyController::isEmergency()) {
                setState(STATE_ERROR, "Cleared Emergency. Must Reset.");
            }
            break;

        case STATE_ERROR:
            // Requires manual stop() or start()
            break;
    }
}

CleaningState CleaningController::getState() { return currentState; }

String CleaningController::getStateName() {
    switch (currentState) {
        case STATE_IDLE: return "IDLE";
        case STATE_PREPARING: return "PREPARING";
        case STATE_WETTING: return "WETTING";
        case STATE_BRUSHING: return "BRUSHING";
        case STATE_SCRUBBING: return "SCRUBBING";
        case STATE_RINSING: return "RINSING";
        case STATE_COMPLETED: return "COMPLETED";
        case STATE_PAUSED: return "PAUSED";
        case STATE_EMERGENCY: return "EMERGENCY";
        case STATE_ERROR: return "ERROR";
        default: return "UNKNOWN";
    }
}

String CleaningController::getStepName() { return currentStep; }
int CleaningController::getProgress() { return progress; }
int CleaningController::getTimeRemaining() { return timeRemaining; }
int CleaningController::getElapsedTime() { return elapsedTime; }
int CleaningController::getCycleCount() { return cleaningCycleCount; }
String CleaningController::getAbortReason() { return abortReason; }
