#ifndef LOGGER_H
#define LOGGER_H

#include <Arduino.h>

class Logger {
public:
    static void init(long baudRate = 115200);
    static void info(const char* module, const char* message);
    static void warning(const char* module, const char* message);
    static void error(const char* module, const char* message);
    static void debug(const char* module, const char* message);
};

#endif // LOGGER_H
