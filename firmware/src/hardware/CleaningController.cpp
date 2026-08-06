#include "hardware/CleaningController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/MotorController.h"
#include "hardware/SensorManager.h"
#include "hardware/EmergencyController.h"
#include "Logger.h"

CleaningState CleaningController::currentState = STATE_IDLE;
CleaningState CleaningController::previousState = STATE_IDLE;
unsigned long CleaningController::stateStartTime = 0;
int CleaningController::progress = 0;
int CleaningController::timeRemaining = 0;
String CleaningController::currentStep = "Idle";

void CleaningController::init() {
    currentState = STATE_IDLE;
    progress = 0;
    timeRemaining = 0;
    currentStep = "Idle";
}

void CleaningController::start() {
    if (currentState == STATE_IDLE || currentState == STATE_COMPLETED || currentState == STATE_ERROR) {
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
        setState(STATE_EMERGENCY, "Emergency Stop");
        PumpController::stop(0);
        PumpController::stop(1);
        BrushController::stop();
        MotorController::stop();
        return;
    }

    if (SensorManager::getWaterLevel() <= 5) {
        Logger::warning("CleaningEngine", "Low Water! Pausing cleaning.");
        pause();
        return;
    }

    if (SensorManager::getSoapLevel() <= 5) {
        Logger::warning("CleaningEngine", "Low Soap! Pausing cleaning.");
        pause();
        return;
    }
}

void CleaningController::tick() {
    executeSafetyChecks();

    unsigned long elapsed = millis() - stateStartTime;

    switch (currentState) {
        case STATE_IDLE:
            progress = 0;
            timeRemaining = 0;
            break;
            
        case STATE_PREPARING:
            progress = 5;
            timeRemaining = 60;
            if (elapsed > 2000) {
                setState(STATE_WETTING, "Spraying Water");
            }
            break;

        case STATE_WETTING:
            progress = 20;
            timeRemaining = 50;
            PumpController::start(0); // Water
            MotorController::moveForward(50);
            
            if (elapsed > 4000) {
                PumpController::stop(0);
                MotorController::stop();
                setState(STATE_BRUSHING, "Applying Soap & Brushing");
            }
            break;

        case STATE_BRUSHING:
            progress = 40;
            timeRemaining = 40;
            PumpController::start(1); // Soap
            BrushController::start();
            MotorController::turnLeft(50);
            
            if (elapsed > 2000 && elapsed < 4000) {
                MotorController::turnRight(50);
            }
            
            if (elapsed > 6000) {
                PumpController::stop(1);
                MotorController::stop();
                setState(STATE_SCRUBBING, "Deep Scrubbing");
            }
            break;

        case STATE_SCRUBBING:
            progress = 65;
            timeRemaining = 25;
            BrushController::start();
            MotorController::moveForward(40);
            
            if (elapsed > 5000) {
                BrushController::stop();
                MotorController::stop();
                setState(STATE_RINSING, "Final Rinse");
            }
            break;

        case STATE_RINSING:
            progress = 85;
            timeRemaining = 10;
            PumpController::start(0); // Water
            MotorController::moveBackward(50);
            
            if (elapsed > 4000) {
                PumpController::stop(0);
                MotorController::stop();
                setState(STATE_COMPLETED, "Done");
            }
            break;

        case STATE_COMPLETED:
            progress = 100;
            timeRemaining = 0;
            if (elapsed > 5000) {
                setState(STATE_IDLE, "Idle");
            }
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
