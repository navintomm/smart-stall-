#ifndef WIFI_SERVER_HANDLER_H
#define WIFI_SERVER_HANDLER_H

#include <WiFi.h>

#define MAX_CLIENTS 3

class WifiServerHandler {
public:
    static void init();
    static void tick();
    static void sendData(const String& data);

private:
    static WiFiServer _server;
    static WiFiClient _clients[MAX_CLIENTS];
    static String _lineBuffers[MAX_CLIENTS];
    static unsigned long _lastHeartbeatTimes[MAX_CLIENTS];
    
    static void processIncomingLine(const String& line);
};

#endif
