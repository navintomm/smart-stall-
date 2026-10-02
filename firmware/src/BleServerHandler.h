#pragma once

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

class BleServerHandler {
public:
    static void init();
    static void tick();
    static void sendData(const String& data);

private:
    static void processIncomingLine(const String& line);

    static BLEServer* pServer;
    static BLECharacteristic* pTxCharacteristic;
    static bool deviceConnected;
    static bool oldDeviceConnected;
    static String rxBuffer;
    static unsigned long lastHeartbeatTime;

    class ServerCallbacks;
    class RxCallbacks;
};
