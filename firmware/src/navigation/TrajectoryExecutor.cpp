#include "TrajectoryExecutor.h"
#include "Logger.h"
#include "../hardware/ServoController.h"
#include "../hardware/EmergencyController.h"
#include "../RobotState.h"

TrajectorySample TrajectoryExecutor::_buffer[MAX_BUFFER_SIZE];
int TrajectoryExecutor::_head = 0;
int TrajectoryExecutor::_tail = 0;
int TrajectoryExecutor::_count = 0;

bool TrajectoryExecutor::_isActive = false;
bool TrajectoryExecutor::_isDryRun = true; // DEFAULT SAFE STATE - DO NOT CHANGE TO FALSE FOR CHECKPOINT 5.2
uint32_t TrajectoryExecutor::_startTimeMs = 0;

void TrajectoryExecutor::init() {
    clearBuffer();
    _isActive = false;
    Logger::info("TrajExec", "TrajectoryExecutor initialized (Dry-Run Mode ENFORCED).");
}

void TrajectoryExecutor::handleControl(const String& action) {
    if (action == "BEGIN") {
        clearBuffer();
        _isActive = false;
        Logger::info("TrajExec", "Trajectory BEGIN received. Awaiting chunks.");
    } else if (action == "END") {
        if (_count >= 2) {
            _isActive = true;
            _startTimeMs = millis();
            RobotState::setMode("DMP_EXEC");
            Logger::info("TrajExec", "Trajectory END received. Execution STARTED (Dry-Run).");
        } else {
            Logger::warning("TrajExec", "Cannot END trajectory: insufficient samples in buffer.");
            abort();
        }
    } else if (action == "ABORT") {
        abort();
        Logger::info("TrajExec", "Trajectory ABORTED by command.");
    }
}

void TrajectoryExecutor::handleChunk(const JsonDocument& payload) {
    if (payload.containsKey("samples")) {
        JsonArrayConst samples = payload["samples"].as<JsonArrayConst>();
        for (JsonVariantConst v : samples) {
            JsonArrayConst sampleArr = v.as<JsonArrayConst>();
            if (sampleArr.size() >= 3) {
                uint32_t t = sampleArr[0].as<uint32_t>();
                float a1 = sampleArr[1].as<float>();
                float a2 = sampleArr[2].as<float>();
                pushSample(t, a1, a2);
            }
        }
    }
}

void TrajectoryExecutor::pushSample(uint32_t t, float a1, float a2) {
    if (_count >= MAX_BUFFER_SIZE) {
        Logger::warning("TrajExec", "Buffer OVERFLOW! Dropping sample.");
        return;
    }
    
    // Non-monotonic check
    if (_count > 0) {
        int prevIdx = (_head == 0) ? (MAX_BUFFER_SIZE - 1) : (_head - 1);
        if (t <= _buffer[prevIdx].timeMs) {
            Logger::warning("TrajExec", "Non-monotonic timestamp detected. Rejecting sample.");
            return;
        }
    }

    _buffer[_head].timeMs = t;
    _buffer[_head].servo1Angle = a1;
    _buffer[_head].servo2Angle = a2;
    
    _head = (_head + 1) % MAX_BUFFER_SIZE;
    _count++;
}

bool TrajectoryExecutor::peekNextSample(TrajectorySample& outSample) {
    if (_count == 0) return false;
    outSample = _buffer[_tail];
    return true;
}

void TrajectoryExecutor::consumeSample() {
    if (_count > 0) {
        _tail = (_tail + 1) % MAX_BUFFER_SIZE;
        _count--;
    }
}

void TrajectoryExecutor::clearBuffer() {
    _head = 0;
    _tail = 0;
    _count = 0;
}

void TrajectoryExecutor::abort() {
    _isActive = false;
    clearBuffer();
    if (RobotState::getMode() == "DMP_EXEC") {
        RobotState::setMode("IDLE");
    }
}

void TrajectoryExecutor::tick() {
    if (!_isActive) return;

    if (EmergencyController::isEmergency()) {
        Logger::error("TrajExec", "Emergency Stop! Aborting Trajectory.");
        abort();
        return;
    }

    uint32_t elapsed = millis() - _startTimeMs;

    // Need at least 2 samples to interpolate
    if (_count < 2) {
        if (_count == 1) { // Reached the end
            TrajectorySample lastSample;
            peekNextSample(lastSample);
            if (elapsed >= lastSample.timeMs) {
                Logger::info("TrajExec", "Trajectory COMPLETE.");
                consumeSample();
                abort();
            }
        } else {
            Logger::warning("TrajExec", "Buffer UNDERFLOW! Aborting Trajectory.");
            abort();
        }
        return;
    }

    // Read current and next sample
    TrajectorySample s0 = _buffer[_tail];
    TrajectorySample s1 = _buffer[(_tail + 1) % MAX_BUFFER_SIZE];

    // If elapsed time is beyond the second sample, consume s0 and advance
    if (elapsed >= s1.timeMs) {
        consumeSample();
        return; // Will interpolate on next tick
    }

    // Wait until we reach the start of the trajectory
    if (elapsed < s0.timeMs) {
        return;
    }

    // Interpolate
    float alpha = (float)(elapsed - s0.timeMs) / (float)(s1.timeMs - s0.timeMs);
    
    // Clamp alpha to [0, 1] for safety
    if (alpha < 0.0f) alpha = 0.0f;
    if (alpha > 1.0f) alpha = 1.0f;

    float desA1 = s0.servo1Angle + alpha * (s1.servo1Angle - s0.servo1Angle);
    float desA2 = s0.servo2Angle + alpha * (s1.servo2Angle - s0.servo2Angle);

    if (_isDryRun) {
        // Output dry-run telemetry at 10Hz to avoid spamming
        static uint32_t lastLog = 0;
        if (millis() - lastLog > 100) {
            char logMsg[128];
            snprintf(logMsg, sizeof(logMsg), "DRY-RUN t=%lu ms | a1=%.2f | a2=%.2f", elapsed, desA1, desA2);
            Logger::info("TrajExec", logMsg);
            lastLog = millis();
        }
    } else {
        // ACTUAL EXECUTION IS DISABLED FOR CHECKPOINT 5.2
        // ServoController::setAngle(1, (int)desA1);
        // ServoController::setAngle(2, (int)desA2);
    }
}
