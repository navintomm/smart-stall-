#ifndef COMMAND_DISPATCHER_H
#define COMMAND_DISPATCHER_H

#include "ProtocolCodec.h"

class CommandDispatcher {
public:
    static void handleCommand(const RobotPacket& packet);
};

#endif // COMMAND_DISPATCHER_H
