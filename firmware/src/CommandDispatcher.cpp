#include "CommandDispatcher.h"
#include "hardware/EmergencyController.h"
#include "hardware/ServoController.h"
#include "hardware/PumpController.h"
#include "hardware/BrushController.h"
#include "RobotState.h"
#include "Logger.h"

void CommandDispatcher::handleCommand(const RobotPacket& packet) {
    if (EmergencyController::isEmergency() && packet.commandId != 402) {
        Logger::warning("CmdDispatch", "System in EMERGENCY state. Ignoring command.");
        return;
    }

    int cmdId = packet.commandId;
    
    switch(cmdId) {
        case 101: // MOVE_FORWARD
            RobotState::setMode("MOVING");
            break;
        case 102: // MOVE_BACKWARD
            RobotState::setMode("MOVING");
            break;
        case 103: // TURN_LEFT
        case 104: // TURN_RIGHT
            RobotState::setMode("MOVING");
            break;
        case 105: // STOP
            RobotState::setMode("IDLE");
            break;
            
        case 201: // BASE_ROTATION
            if (packet.payload.containsKey("angle")) {
                ServoController::setAngle(0, packet.payload["angle"].as<int>());
            }
            break;
            
        case 301: // WATER_PUMP
            if (packet.payload["state"].as<bool>()) PumpController::start(0);
            else PumpController::stop(0);
            break;
        case 302: // SOAP_PUMP
            if (packet.payload["state"].as<bool>()) PumpController::start(1);
            else PumpController::stop(1);
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
            
        default:
            Logger::warning("CmdDispatch", "Unknown Command ID.");
            break;
    }
}
