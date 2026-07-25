#ifndef WIFI_SERVER_HANDLER_H
#define WIFI_SERVER_HANDLER_H

#include <WiFi.h>

class WifiServerHandler {
public:
    static void init();
    static void tick();
    static void sendData(const String& data);

private:
    static WiFiServer _server;
    static WiFiClient _client;
    static String _lineBuffer;
    
    static void processIncomingLine(const String& line);
};

#endif // WIFI_SERVER_HANDLER_H
