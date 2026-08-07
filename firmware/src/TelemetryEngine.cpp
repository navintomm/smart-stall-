#include "TelemetryEngine.h"
#include "Config.h"
#include "RobotState.h"
#include "ProtocolCodec.h"
#include "hardware/SensorManager.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/EmergencyController.h"
#include "hardware/ServoController.h"
#include "hardware/MotorController.h"
#include "hardware/CleaningController.h"
#include "vision/CameraManager.h"
#include "vision/CalibrationManager.h"
#include "vision/LocalizationEngine.h"
#include "vision/AlignmentEngine.h"
#include "vision/PoseEstimator.h"
#include "navigation/MissionPlanner.h"
#include "navigation/NavigationController.h"
#include "SystemHealthManager.h"
#include "config/pin_map.h"
#include <WiFi.h>

unsigned long TelemetryEngine::_lastTelemetryTime = 0;

void TelemetryEngine::init() {
    _lastTelemetryTime = millis();
}

void TelemetryEngine::tick(void (*sendCallback)(const String&)) {
    unsigned long currentMillis = millis();
    
    if (currentMillis - _lastTelemetryTime >= Config::TELEMETRY_INTERVAL_MS) {
        _lastTelemetryTime = currentMillis;

        RobotPacket packet;
        packet.type = "telemetry";
        packet.protocolVersion = Config::PROTOCOL_VERSION;
        packet.timestamp = currentMillis;
        packet.sequenceNumber = currentMillis; // Simple placeholder seq
        
        packet.payload["bat"] = SensorManager::getBatteryLevel();
        packet.payload["bat_v"] = SensorManager::getBatteryVoltage();
        packet.payload["water"] = SensorManager::getWaterLevel();
        packet.payload["soap"] = SensorManager::getSoapLevel();
        packet.payload["temp"] = SensorManager::getMotorTemp();
        packet.payload["obs"] = SensorManager::getObstacleDistance();
        
        packet.payload["pump_w"] = PumpController::getStatus(0);
        packet.payload["pump_s"] = PumpController::getStatus(1);
        packet.payload["brush"] = BrushController::getStatus();
        
        packet.payload["emg"] = EmergencyController::isEmergency();
        // Hardware switch is active LOW, so !digitalRead
        packet.payload["emg_sw"] = (digitalRead(Pins::EMERGENCY_SWITCH) == LOW);

        packet.payload["motor_speed"] = MotorController::getCurrentSpeed();
        packet.payload["motor_dir"] = MotorController::getCurrentDirection();
        
        // Use a nested JSON object or array for servo angles
        JsonArray servos = packet.payload["servos"].to<JsonArray>();
        for(int i=0; i<5; i++) {
            servos.add(ServoController::getAngle(i));
        }

        #ifdef ESP32
        packet.payload["rssi"] = WiFi.RSSI();
        #else
        packet.payload["rssi"] = -50;
        #endif

        packet.payload["mode"] = RobotState::getMode();
        packet.payload["clean_state"] = CleaningController::getStateName();
        packet.payload["clean_step"] = CleaningController::getStepName();
        packet.payload["clean_progress"] = CleaningController::getProgress();
        packet.payload["clean_remaining"] = CleaningController::getTimeRemaining();
        packet.payload["clean_elapsed"] = CleaningController::getElapsedTime();
        packet.payload["clean_cycle"] = CleaningController::getCycleCount();
        packet.payload["abort_reason"] = CleaningController::getAbortReason();
        
        packet.payload["cam_status"] = CameraManager::isHealthy() ? "OK" : "ERROR";
        packet.payload["cam_calibrated"] = CalibrationManager::isCalibrated();
        packet.payload["cam_fps"] = CameraManager::getFPS();
        packet.payload["marker_id"] = LocalizationEngine::getMarkerId();
        
        Pose pose = PoseEstimator::getLatestPose();
        packet.payload["marker_dist"] = pose.distance;
        packet.payload["marker_conf"] = LocalizationEngine::getConfidence();
        packet.payload["loc_state"] = LocalizationEngine::getStateName();
        
        AlignmentData align = AlignmentEngine::getAlignment();
        packet.payload["align_score"] = align.alignmentScore;
        packet.payload["pose_x"] = pose.x;
        packet.payload["pose_y"] = pose.y;
        packet.payload["pose_z"] = pose.z;
        packet.payload["pose_roll"] = pose.roll;
        packet.payload["pose_pitch"] = pose.pitch;
        packet.payload["pose_yaw"] = pose.yaw;
        packet.payload["last_det_time"] = LocalizationEngine::getLastDetectionTime();
        
        packet.payload["mission_state"] = MissionPlanner::getStateName();
        packet.payload["current_waypoint"] = MissionPlanner::getCurrentWaypointId();
        packet.payload["target_waypoint"] = MissionPlanner::getTargetWaypointId();
        packet.payload["navigation_progress"] = MissionPlanner::getNavigationProgress();
        packet.payload["distance_remaining"] = NavigationController::getDistanceRemaining();
        packet.payload["mission_time"] = MissionPlanner::getMissionTime();
        packet.payload["mission_count"] = MissionPlanner::getMissionCount();
        packet.payload["nav_state"] = NavigationController::getStateName();

        // System Health
        packet.payload["sys_loop_ms"] = SystemHealthManager::getMaxLoopTimeMs();
        packet.payload["sys_fps"] = SystemHealthManager::getLoopFps();
        packet.payload["sys_heap"] = SystemHealthManager::getFreeHeap();
        packet.payload["sys_wdg"] = SystemHealthManager::isWatchdogTriggered();
        
        packet.payload["uptime"] = currentMillis / 1000;

        String outJson;
        ProtocolCodec::encode(packet, outJson);
        
        // Append newline delimiter
        outJson += "\n";
        
        if (sendCallback != nullptr) {
            sendCallback(outJson);
        }
    }
}
