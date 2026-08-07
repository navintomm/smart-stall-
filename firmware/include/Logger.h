#ifndef LOGGER_H
#define LOGGER_H

#include <Arduino.h>

class Logger {
private:
    static String sessionId;
    static void printFormatted(const char* level, const char* module, const char* message);

public:
    static void init(long baudRate = 115200);
    static void setSessionId(const String& id);
    
    static void info(const char* module, const char* message);
    static void info(const char* module, const String& message);
    
    static void warning(const char* module, const char* message);
    static void warning(const char* module, const String& message);
    
    static void error(const char* module, const char* message);
    static void error(const char* module, const String& message);
    
    static void debug(const char* module, const char* message);
    static void debug(const char* module, const String& message);
    
    static void critical(const char* module, const char* message);
    static void critical(const char* module, const String& message);
};

#endif // LOGGER_H
