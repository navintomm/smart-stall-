#include "Logger.h"

void Logger::init(long baudRate) {
    Serial.begin(baudRate);
    while (!Serial) {
        ; // wait for serial port to connect
    }
    Serial.println("\n[SYSTEM] Logger initialized.");
}

void Logger::info(const char* module, const char* message) {
    Serial.printf("[INFO] [%s] %s\n", module, message);
}

void Logger::warning(const char* module, const char* message) {
    Serial.printf("[WARN] [%s] %s\n", module, message);
}

void Logger::error(const char* module, const char* message) {
    Serial.printf("[ERROR] [%s] %s\n", module, message);
}

void Logger::debug(const char* module, const char* message) {
    // Debug can be #ifdef'd out for production builds
    Serial.printf("[DEBUG] [%s] %s\n", module, message);
}
