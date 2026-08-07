#include "CommandDispatcher.h"
#include "hardware/EmergencyController.h"
#include "hardware/ServoController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/MotorController.h"
#include "hardware/SensorManager.h"
#include "hardware/CleaningController.h"
#include "navigation/MissionPlanner.h"
#include "WifiServerHandler.h"
#include "RobotState.h"
#include "Logger.h"
#include "vision/ArucoDetector.h"
#include "vision/PoseEstimator.h"
#include "vision/AlignmentEngine.h"
#include "vision/CalibrationManager.h"

void CommandDispatcher::handleCommand(const RobotPacket& packet) {
    if (EmergencyController::isEmergency() && packet.commandId != 402) {
        Logger::warning("CmdDispatch", "System in EMERGENCY state. Ignoring command.");
        return;
    }

    int cmdId = packet.commandId;
    
    RobotPacket ackPacket;
    ackPacket.type = "ack";
    ackPacket.protocolVersion = packet.protocolVersion;
    ackPacket.sequenceNumber = packet.sequenceNumber;
    ackPacket.commandId = packet.commandId;
    ackPacket.timestamp = millis();
    
    switch(cmdId) {
        case 101: // MOVE_FORWARD
            if (packet.payload.containsKey("speed")) {
                MotorController::moveForward(packet.payload["speed"].as<int>());
                RobotState::setMode("MOVING");
            }
            break;
        case 102: // MOVE_BACKWARD
            if (packet.payload.containsKey("speed")) {
                MotorController::moveBackward(packet.payload["speed"].as<int>());
                RobotState::setMode("MOVING");
            }
            break;
        case 103: // TURN_LEFT
            if (packet.payload.containsKey("speed")) {
                MotorController::turnLeft(packet.payload["speed"].as<int>());
                RobotState::setMode("MOVING");
            }
            break;
        case 104: // TURN_RIGHT
            if (packet.payload.containsKey("speed")) {
                MotorController::turnRight(packet.payload["speed"].as<int>());
                RobotState::setMode("MOVING");
            }
            break;
        case 105: // STOP
            MotorController::stop();
            RobotState::setMode("IDLE");
            break;
            
        case 201: // BASE_ROTATION
            if (packet.payload.containsKey("angle")) {
                ServoController::setAngle(0, packet.payload["angle"].as<int>());
            }
            break;
            
        case 301: // WATER_PUMP
            if (packet.payload["state"].as<bool>()) {
                if (SensorManager::getWaterLevel() <= 5) {
                    Logger::warning("CmdDispatch", "Water Tank Empty! Aborting Water Pump start.");
                    ackPacket.type = "error";
                    ackPacket.payload["status"] = "ERROR_WATER_EMPTY";
                } else {
                    PumpController::start(0);
                }
            } else {
                PumpController::stop(0);
            }
            break;
        case 302: // SOAP_PUMP
            if (packet.payload["state"].as<bool>()) {
                if (SensorManager::getSoapLevel() <= 5) {
                    Logger::warning("CmdDispatch", "Soap Tank Empty! Aborting Soap Pump start.");
                    ackPacket.type = "error";
                    ackPacket.payload["status"] = "ERROR_SOAP_EMPTY";
                } else {
                    PumpController::start(1);
                }
            } else {
                PumpController::stop(1);
            }
            break;
        case 303: // BRUSH_MOTOR
            if (packet.payload["state"].as<bool>()) BrushController::start();
            else BrushController::stop();
            break;
            
        case 401: // EMERGENCY_STOP
            EmergencyController::triggerEmergencyStop();
            RobotState::setMode("EMERGENCY");
            break;
        case 402: // RESUME (Clear Emergency)
            EmergencyController::reset();
            RobotState::setMode("IDLE");
            break;
        case 406: // PING
            Logger::info("CmdDispatch", "PING received.");
            break;
            
        case 501: // START_CLEANING
            CleaningController::start();
            RobotState::setMode("AUTO_CLEAN");
            break;
        case 502: // PAUSE_CLEANING
            CleaningController::pause();
            RobotState::setMode("PAUSED");
            break;
        case 503: // RESUME_CLEANING
            CleaningController::resume();
            RobotState::setMode("AUTO_CLEAN");
            break;
        case 504: // STOP_CLEANING
            CleaningController::stop();
            RobotState::setMode("IDLE");
            break;

        case 601: { // MISSION_START
            if (packet.payload.containsKey("waypoints")) {
                JsonArray arr = packet.payload["waypoints"].as<JsonArray>();
                int wps[10];
                int count = 0;
                for (JsonVariant v : arr) {
                    if (count < 10) {
                        wps[count++] = v.as<int>();
                    }
                }
                MissionPlanner::startMission(wps, count);
                RobotState::setMode("MISSION");
            }
            break;
        }
        case 602: // MISSION_PAUSE
            MissionPlanner::pauseMission();
            RobotState::setMode("PAUSED");
            break;
        case 603: // MISSION_RESUME
            MissionPlanner::resumeMission();
            RobotState::setMode("MISSION");
            break;
        case 604: // MISSION_CANCEL
            MissionPlanner::cancelMission();
            RobotState::setMode("IDLE");
            break;
            
        case 701: // VISION_TELEMETRY
            if (packet.payload.containsKey("marker_id")) {
                int mId = packet.payload["marker_id"].as<int>();
                float conf = packet.payload["marker_conf"].as<float>();
                ArucoDetector::setDetection(mId, conf);
                
                float x = packet.payload["pose_x"].as<float>();
                float y = packet.payload["pose_y"].as<float>();
                float z = packet.payload["pose_z"].as<float>();
                float r = packet.payload["pose_roll"].as<float>();
                float p = packet.payload["pose_pitch"].as<float>();
                float yw = packet.payload["pose_yaw"].as<float>();
                float d = packet.payload["marker_dist"].as<float>();
                PoseEstimator::setPose(x, y, z, r, p, yw, d);
                
                int score = packet.payload["align_score"].as<int>();
                AlignmentEngine::setAlignmentScore(score);
                
                bool calib = packet.payload["cam_calibrated"].as<bool>();
                CalibrationManager::setCalibrated(calib);
            }
            break;
            
        default:
            Logger::warning("CmdDispatch", "Unknown Command ID.");
            return; // Exit without ACK if invalid
    }

    // Send ACK Response
    // (If not already modified to an error)
    if (!ackPacket.payload.containsKey("status")) {
        ackPacket.payload["status"] = "OK";
    }
    
    String outJson;
    ProtocolCodec::encode(ackPacket, outJson);
    outJson += "\n";
    WifiServerHandler::sendData(outJson);
}
