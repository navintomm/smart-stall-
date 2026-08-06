#include "CommandDispatcher.h"
#include "hardware/EmergencyController.h"
#include "hardware/ServoController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "hardware/MotorController.h"
#include "hardware/SensorManager.h"
#include "hardware/CleaningController.h"
#include "WifiServerHandler.h"
#include "RobotState.h"
#include "Logger.h"

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
