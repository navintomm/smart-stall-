#include "Logger.h"

String Logger::sessionId = "BOOT";

void Logger::init(long baudRate) {
    Serial.begin(baudRate);
    while (!Serial) {
        ; // wait for serial port to connect
    }
    Serial.println("\n[SYSTEM] Logger initialized.");
}

void Logger::setSessionId(const String& id) {
    sessionId = id;
}

void Logger::printFormatted(const char* level, const char* module, const char* message) {
    unsigned long time = millis();
    Serial.printf("[%lu] [%s] [%s] [%s] %s\n", time, sessionId.c_str(), level, module, message);
}

void Logger::info(const char* module, const char* message) { printFormatted("INFO", module, message); }
void Logger::info(const char* module, const String& message) { printFormatted("INFO", module, message.c_str()); }

void Logger::warning(const char* module, const char* message) { printFormatted("WARN", module, message); }
void Logger::warning(const char* module, const String& message) { printFormatted("WARN", module, message.c_str()); }

void Logger::error(const char* module, const char* message) { printFormatted("ERROR", module, message); }
void Logger::error(const char* module, const String& message) { printFormatted("ERROR", module, message.c_str()); }

void Logger::debug(const char* module, const char* message) {
#ifndef DISABLE_DEBUG_LOGS
    printFormatted("DEBUG", module, message);
#endif
}
void Logger::debug(const char* module, const String& message) { debug(module, message.c_str()); }

void Logger::critical(const char* module, const char* message) { printFormatted("CRITICAL", module, message); }
void Logger::critical(const char* module, const String& message) { printFormatted("CRITICAL", module, message.c_str()); }
